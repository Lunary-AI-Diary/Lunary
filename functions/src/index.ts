import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

admin.initializeApp();

const region = 'asia-northeast3'; // 서울 리전

async function purgeUserData(uid: string) {
  const db = admin.firestore();
  const userRef = db.collection('users').doc(uid);

  try {
    await db.recursiveDelete(userRef);
    functions.logger.info(`purged Firestore subtree users/${uid}`);
  } catch (e) {
    functions.logger.error(`recursiveDelete failed for users/${uid}`, e as Error);
    throw e;
  }
}

// 1) callable
export const deleteMyAccount = functions
  .region(region)
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }
    const uid = context.auth.uid!;

    // 1-1. 데이터 먼저 삭제
    await purgeUserData(uid);

    // 1-2. 계정 삭제(관리자 권한으로 최근 로그인 제한 없음)
    await admin.auth().deleteUser(uid);

    // onUserDeleted 트리거가 추가로 호출되어도 문제없음(멱등)
    return { ok: true };
  });

// 2) Auth 트리거
export const onAuthUserDeleted = functions
  .region(region)
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;
    try {
      await purgeUserData(uid);
    } catch (e) {
      functions.logger.error(`onAuthUserDeleted purge failed for ${uid}`, e as Error);
    }
  });

// 3) HTTP 엔드포인트(플레이 제출용)
export const accountDeletion = functions
  .region(region)
  .https.onRequest(async (req, res) => {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    if (req.method === 'OPTIONS') {
      res.status(204).send();
      return;
    }

    if (req.method === 'GET') {
      // 간단한 안내 페이지(플레이 콘솔에 이 URL 제출)
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.status(200).send(`
        <!doctype html>
        <html lang="ko"><head><meta charset="utf-8"><title>계정 삭제 안내</title></head>
        <body style="font-family:sans-serif; max-width:720px; margin:40px auto; line-height:1.6">
          <h1>Lunary 계정/데이터 삭제 안내</h1>
          <ol>
            <li>앱에서: 설정 -> 프로필 -> 회원탈퇴 버튼으로 계정과 모든 데이터를 즉시 삭제할 수 있습니다.</li>
            <li>앱 접근이 어려울 경우:
              <ul>
                <li>아래 API에 Firebase ID 토큰으로 POST 요청을 보내 삭제를 진행할 수 있습니다.</li>
                <li>또는 jls15900@gmail.com 으로 “계정 삭제 요청” 메일을 보내주세요.</li>
              </ul>
            </li>
          </ol>
          <p>API: POST ${req.protocol}://${req.get('host')}${req.path}</p>
          <pre>헤더: Content-Type: application/json
  바디: {"idToken": "[Firebase ID 토큰]"}</pre>
          <p>ID 토큰은 Firebase 클라이언트 SDK로 발급받을 수 있습니다.</p>
        </body></html>
      `);
      return;
    }

    if (req.method === 'POST') {
      try {
        const idToken = (req.body && req.body.idToken) || '';
        if (!idToken) {
          res.status(400).json({ error: 'idToken is required' });
          return;
        }

        const decoded = await admin.auth().verifyIdToken(idToken);
        const uid = decoded.uid;

        await purgeUserData(uid);
        await admin.auth().deleteUser(uid);

        res.status(200).json({ ok: true });
        return;
      } catch (e) {
        res.status(400).json({ error: (e as Error).message });
        return;
      }
    }

    res.status(405).send('Method Not Allowed');
    return;
  });
