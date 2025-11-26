import { gemini } from "./api.js";

const output = document.getElementById("verify-output");
const box = document.getElementById("verify-results");

function show(text) {
    box.style.display = "block";
    output.innerHTML = marked.parse(text);
}

// --- TEXT ---
document.getElementById("text-verify-btn").onclick = async () => {
    const msg = document.getElementById("text-input").value.trim();
    if (!msg) return;

    const res = await gemini(`Analyze this message for scams:\n${msg}`);
    show(res.text);
};

// --- PHONE ---
document.getElementById("phone-verify-btn").onclick = async () => {
    const number = document.getElementById("phone-input").value.trim();
    const org = document.getElementById("org-input").value.trim();

    const res = await gemini(
        `Check if phone number ${number} is linked to scam. They claim to be ${org}.`,
        { google: true }
    );

    show(res.text);
};

