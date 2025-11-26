import { gemini } from "./api.js";

const input = document.getElementById("chat-input");
const history = document.getElementById("chat-history");

document.getElementById("chat-send").onclick = async () => {
    const msg = input.value.trim();
    if (!msg) return;

    append("user", msg);
    input.value = "";

    const reply = await gemini(msg, { system: "You are RadarSafi, speak in Swahili + English blend." });
    append("ai", reply.text);
};

function append(who, text) {
    const div = document.createElement("div");
    div.className = who === "user" ? "text-right mb-2" : "text-left mb-2";
    div.innerHTML = `<span class="inline-block p-2 rounded-lg ${who==="user"?"bg-blue-100":"bg-gray-200"}">${text}</span>`;
    history.appendChild(div);
    history.scrollTop = history.scrollHeight;
}

