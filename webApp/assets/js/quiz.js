import { gemini } from "./api.js";

const qBox = document.getElementById("quiz-question");
const optBox = document.getElementById("quiz-options");
const nextBtn = document.getElementById("next-question-btn");

async function loadQ() {
    nextBtn.style.display = "none";
    const res = await gemini("Generate a cybersecurity quiz question with 4 options and correct answer.");
    const parsed = JSON.parse(res.text);

    qBox.textContent = parsed.question;
    optBox.innerHTML = "";

    parsed.options.forEach((opt, i) => {
        const btn = document.createElement("button");
        btn.className = "p-3 bg-gray-100 rounded";
        btn.textContent = opt;
        btn.onclick = () => check(opt, parsed.answer);
        optBox.appendChild(btn);
    });
}

function check(selected, correct) {
    let text = selected === correct ? "✅ Correct!" : `❌ Wrong. Correct answer: ${correct}`;
    document.getElementById("quiz-feedback").style.display = "block";
    document.getElementById("feedback-title").textContent = "Result";
    document.getElementById("feedback-text").textContent = text;
    nextBtn.style.display = "block";
}

nextBtn.onclick = loadQ;
loadQ();

