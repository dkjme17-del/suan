const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Mets ici le chemin vers ta clé de service

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function addOrderField() {
  const snapshot = await db.collection('quiz_categories').get();
  let order = 1;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.order === undefined) {
      await doc.ref.update({ order });
      console.log(`Ajout de order=${order} à ${doc.id}`);
    } else {
      console.log(`Déjà présent pour ${doc.id} (order=${data.order})`);
    }
    order++;
  }
  console.log('✅ Correction terminée');
}

addOrderField().catch(console.error);