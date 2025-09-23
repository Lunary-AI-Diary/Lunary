// Firebase Web SDK (compat) 불러오기
// 이 파일은 HTML에서 <script src="/accountDeletionJs"></script>로 불러옴.

const firebaseConfig = window.FIREBASE_CONFIG;

firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();

const signedOutView = document.getElementById("signedOutView");
const signedInView = document.getElementById("signedInView");
const resultView = document.getElementById("resultView");
const userInfoEl = document.getElementById("userInfo");
const statusEl = document.getElementById("status");

function setView(state) {
  signedOutView.classList.toggle("hidden", state !== "out");
  signedInView.classList.toggle("hidden", state !== "in");
  resultView.classList.toggle("hidden", state !== "result");
}

auth.onAuthStateChanged((user) => {
  if (user) {
    userInfoEl.textContent =
      "UID: " +
      user.uid +
      " | 이메일: " +
      (user.email || "(없음)") +
      " | 이름: " +
      (user.displayName || "(없음)");
    setView("in");
  } else {
    setView("out");
  }
});

document
  .getElementById("emailSignInBtn")
  .addEventListener("click", async () => {
    const email = /** @type {HTMLInputElement} */ (
      document.getElementById("email")
    ).value.trim();
    const password = /** @type {HTMLInputElement} */ (
      document.getElementById("password")
    ).value;
    try {
      await auth.signInWithEmailAndPassword(email, password);
    } catch (e) {
      alert("로그인 실패: " + (e.message || e));
    }
  });

document
  .getElementById("googleSignInBtn")
  .addEventListener("click", async () => {
    const provider = new firebase.auth.GoogleAuthProvider();
    try {
      await auth.signInWithPopup(provider);
    } catch (e) {
      await auth.signInWithRedirect(provider);
    }
  });

document.getElementById("signOutBtn").addEventListener("click", async () => {
  await auth.signOut();
});

document.getElementById("deleteBtn").addEventListener("click", async () => {
  const user = auth.currentUser;
  if (!user) return;
  if (
    !confirm(
      "정말로 계정과 모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다."
    )
  )
    return;

  try {
    const idToken = await user.getIdToken(true);
    const resp = await fetch(window.location.href, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + idToken,
      },
      body: JSON.stringify({}),
    });

    if (!resp.ok) {
      const err = await resp.json().catch(() => ({}));
      throw new Error(err.error || "HTTP " + resp.status);
    }

    setView("result");
    statusEl.textContent = "계정과 데이터가 성공적으로 삭제되었습니다.";
    try {
      await auth.signOut();
    } catch (_) {}
  } catch (e) {
    setView("result");
    statusEl.textContent = "삭제 실패: " + (e.message || e);
  }
});
