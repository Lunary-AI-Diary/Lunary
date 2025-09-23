import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp();

const region = "asia-northeast3"; // 서울 리전

async function purgeUserData(uid: string) {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(uid);

  try {
    await db.recursiveDelete(userRef);
    functions.logger.info(`purged Firestore subtree users/${uid}`);
  } catch (e) {
    functions.logger.error(
      `recursiveDelete failed for users/${uid}`,
      e as Error
    );
    throw e;
  }
}

// 1) callable
export const deleteMyAccount = functions
  .region(region)
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }
    const uid = context.auth.uid!;

    await purgeUserData(uid);

    await admin.auth().deleteUser(uid);

    return { ok: true };
  });

// 2) Auth 트리거
export const onAuthUserDeleted = functions
  .region(region)
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;
    try {
      await purgeUserData(uid);
    } catch (e) {
      functions.logger.error(
        `onAuthUserDeleted purge failed for ${uid}`,
        e as Error
      );
    }
  });

// 3) HTTP 엔드포인트(사용자가 직접 로그인하고 삭제할 수 있는 페이지 + API)
export const accountDeletionJs = functions
  .region(region)
  .https.onRequest((req, res) => {
    res.setHeader("Content-Type", "application/javascript; charset=utf-8");
    try {
      const jsPath = path.join(__dirname, "../assets/account-deletion.js"); // ← 변경
      res.send(fs.readFileSync(jsPath, "utf8"));
    } catch (e) {
      functions.logger.error("JS file read failed", e as Error);
      res.status(500).send("Internal Server Error");
    }
  });

export const accountDeletionCss = functions
  .region(region)
  .https.onRequest((req, res) => {
    res.setHeader("Content-Type", "text/css; charset=utf-8");
    try {
      const cssPath = path.join(__dirname, "../assets/account-deletion.css"); // ← 변경
      res.send(fs.readFileSync(cssPath, "utf8"));
    } catch (e) {
      functions.logger.error("CSS file read failed", e as Error);
      res.status(500).send("Internal Server Error");
    }
  });

const webConfig = (functions.config() as any).web || {};

export const accountDeletion = functions
  .region("asia-northeast3")
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .https.onRequest(async (req, res) => {
    // CORS
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader(
      "Access-Control-Allow-Headers",
      "Content-Type, Authorization"
    );
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Max-Age", "3600");

    if (req.method === "OPTIONS") {
      res.status(204).send();
      return;
    }

    if (req.method === "GET") {
      try {
        const htmlPath = path.join(__dirname, "../assets/account-deletion.html"); // ← 변경
        let html = fs.readFileSync(htmlPath, "utf8");
        html = html
          .replace("__API_KEY__", (webConfig.api_key || ""))
          .replace("__AUTH_DOMAIN__", (webConfig.auth_domain || ""))
          .replace("__PROJECT_ID__", (webConfig.project_id || ""))
          .replace("__APP_ID__", (webConfig.app_id || ""))
          .replace("__STORAGE_BUCKET__", (webConfig.storage_bucket || ""))
          .replace("__MESSAGING_SENDER_ID__", (webConfig.messaging_sender_id || ""))
          .replace("__MEASUREMENT_ID__", (webConfig.measurement_id || ""));
        const apiUrl = `${req.protocol}://${req.get("host")}${req.path}`;
        html = html.replace("__API_URL__", apiUrl);
        res.setHeader("Content-Type", "text/html; charset=utf-8");
        res.status(200).send(html);
        return;
      } catch (e) {
        functions.logger.error("HTML file read failed", e as Error);
        res.status(500).send("Internal Server Error");
        return;
      }
    }

    if (req.method === "POST") {
      try {
        const authHeader = req.get("Authorization") || "";
        let idToken = (req.body && req.body.idToken) || "";
        if (!idToken && authHeader.startsWith("Bearer ")) {
          idToken = authHeader.substring(7);
        }
        if (!idToken) {
          res.status(400).json({ error: "idToken is required" });
          return;
        }

        // revoke된 토큰 거부
        const decoded = await admin.auth().verifyIdToken(idToken, true);
        const uid = decoded.uid;

        await purgeUserData(uid);
        await admin.auth().deleteUser(uid);

        res.status(200).json({ ok: true });
        return;
      } catch (e) {
        // 내부 오류 상세 노출 자제
        res
          .status(400)
          .json({
            error: "유효하지 않은 요청이거나 처리 중 오류가 발생했습니다.",
          });
        return;
      }
    }

    res.status(405).send("Method Not Allowed");
    return;
  });
