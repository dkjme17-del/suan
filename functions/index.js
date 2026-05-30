const functions = require('firebase-functions');
const { defineSecret, defineString } = require('firebase-functions/params');
const express = require('express');
const cors = require('cors');
const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '.env'), override: true });

const GEMINI_API_KEY_SECRET = defineSecret('gemini.key');
const GEMINI_MODEL_PARAM = defineString('gemini.model', { default: 'models/gemini-flash-latest' });

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '10mb' }));

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || process.env.GEMINI_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || GEMINI_MODEL_PARAM.value();

function getModelPath(model) {
  return model.startsWith('models/') ? model : `models/${model}`;
}

app.post('/chat', async (req, res) => {
  try {
    const { messages, context } = req.body;
    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: 'Messages invalides' });
    }
    if (!GEMINI_API_KEY) {
      return res.status(503).json({ error: 'GEMINI_API_KEY non configuré. Ajoute-le dans les configs Firebase ou .env puis redémarre.' });
    }

    const systemPrompt = `Tu es AKWABA, tuteur francophone spécialisé en BAOULÉ.

OBJECTIF: Enseigner le BAOULÉ avec pédagogie et précision.

RÈGLES STRICTES:
1. Écris toujours le BAOULÉ en MAJUSCULES.
2. Réponds en français clair et fournis le BAOULÉ complet.
3. Ne JAMAIS inventer ou deviner des formes BAOULÉ.
4. Si tu n'es pas certain d'une traduction, réponds uniquement: "Je suis incertain"
5. Pour une traduction, détaille d'abord chaque mot français, puis donne la phrase BAOULÉ complète.
6. Limite la réponse à 200 mots.
7. Si tu corriges une phrase, indique la correction suivie d'une explication courte.

FORMAT OBLIGATOIRE:
Requête: <texte de l'apprenant>
Français: <texte en français>
BAOULÉ LITTÉRAL: <mot1 FR → mot1 BAOULÉ ; mot2 FR → mot2 BAOULÉ ; ...>
BAOULÉ NATUREL: <phrase BAOULÉ complète en MAJUSCULES>
Explication: <explication courte en français>

CONTEXTE: Enseignement du BAOULÉ pour apprenants francophones

${context ? `SCÉNARIO: ${context}` : ''}`;

    const fewShot = `

EXEMPLE DE FORMAT STRICT:

Requête: "Bonjour"
Français: Bonjour
BAOULÉ LITTÉRAL: Bonjour → [mot baoulé littéral]
BAOULÉ NATUREL: [phrase baoulé complète]
Explication: [courte explication en français]

Requête: "Merci"
Français: Merci
BAOULÉ LITTÉRAL: Merci → [mot baoulé littéral]
BAOULÉ NATUREL: [phrase baoulé complète]
Explication: [courte explication en français]

FIN_EXEMPLES
`;

    const effectiveSystemPrompt = fewShot + '\n' + systemPrompt;

    const geminiContents = messages.map(m => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    const { default: fetch } = await import('node-fetch');
    const controller = new AbortController();
    const timeoutMs = Number(process.env.GEMINI_TIMEOUT_MS || 30000);
    const timeout = setTimeout(() => controller.abort(), timeoutMs);

    const modelPath = getModelPath(GEMINI_MODEL);
    const supportsGenerateContent = GEMINI_MODEL.toLowerCase().includes('gemini');
    const methodName = supportsGenerateContent ? 'generateContent' : 'generateText';
    const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/${modelPath}:${methodName}?key=${GEMINI_API_KEY}`;

    let response;
    if (supportsGenerateContent) {
      response = await fetch(GEMINI_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          system_instruction: { parts: [{ text: effectiveSystemPrompt || systemPrompt }] },
          contents: geminiContents,
          generationConfig: { temperature: 0.0, maxOutputTokens: 1024 }
        }),
        signal: controller.signal,
      });
    } else {
      const promptParts = [systemPrompt, ''];
      for (const m of messages) {
        promptParts.push(`${m.role.toUpperCase()}: ${m.content}`);
      }
      const promptText = promptParts.join('\n\n');
      response = await fetch(GEMINI_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: { text: (effectiveSystemPrompt || systemPrompt) + '\n\n' + promptText }, temperature: 0.0, maxOutputTokens: 1024 }),
        signal: controller.signal,
      });
    }

    clearTimeout(timeout);
    const raw = await response.text();
    let data;
    try {
      data = raw ? JSON.parse(raw) : null;
    } catch (e) {
      data = raw;
    }

    if (!response.ok) {
      console.error('Gemini Error status', response.status, 'raw:', raw || JSON.stringify(data));
      return res.status(response.status).json({ error: data?.error?.message || raw || `Erreur API Gemini (${response.status})`, details: data ?? raw });
    }

    const candidate0 = data?.candidates?.[0] || {};
    const content = candidate0.output || candidate0.content?.[0]?.text || candidate0.content?.parts?.[0]?.text || data?.output?.[0]?.content?.[0]?.text || data?.result || data?.text;
    const reply = (typeof content === 'string') ? content.trim() : JSON.stringify(content);
    return res.json({ response: reply });
  } catch (error) {
    console.error('Erreur fonction chat:', error);
    return res.status(500).json({ error: 'Erreur interne', details: String(error) });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: '✅ Firebase Functions AKWABA ready!', model: GEMINI_MODEL, apiKeySet: !!GEMINI_API_KEY });
});

exports.chat = functions.runWith({
  secrets: [GEMINI_API_KEY_SECRET]
}).https.onRequest(app);
