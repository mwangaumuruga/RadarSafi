export const API_MODEL = "gemini-2.5-flash-preview-09-2025";

export async function gemini(prompt, { image=null, google=false, system=null } = {}) {
    const apiKey = document.getElementById("api-key")?.value;
    if (!apiKey) return { text: "❌ Missing API key." };

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${API_MODEL}:generateContent?key=${apiKey}`;

    let parts = [{ text: prompt }];
    if (image) parts.push({ inlineData: { mimeType: "image/jpeg", data: image } });

    const payload = { contents: [{ parts }] };

    if (google) {
        payload.tools = [{ google_search: {} }];
        payload.systemInstruction = {
            parts: [{ text: "Use Google Search for accurate facts and cite your sources." }]
        };
    }

    if (system && !google) {
        payload.systemInstruction = { parts: [{ text: system }] };
    }

    const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });

    const data = await res.json();
    const candidate = data.candidates?.[0]?.content?.parts?.[0]?.text || "No response";

    return { text: candidate };
}

