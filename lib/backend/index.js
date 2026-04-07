const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(cors());
app.use(express.json());

const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({error: 'No token'});

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({error: 'Invalid token'});
  }
};

app.get('/api/devices', verifyToken, async (req, res) => {
  const { status, location } = req.query;
  let query = admin.firestore().collection('devices');

  if (status) query = query.where('status', '==', status);
  if (location) query = query.where('location', '==', location);

  const snapshot = await query.get();
  const devices = snapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));
  res.json(devices);
});

app.get('/api/devices/:id', verifyToken, async (req, res) => {
  const doc = await admin.firestore().collection('devices').doc(req.params.id).get();
  if (!doc.exists) return res.status(404).json({error: 'Device not found'});
  res.json({id: doc.id, ...doc.data()});
});

app.post('/api/devices', verifyToken, async (req, res) => {
  await admin.firestore().collection('devices').add(req.body);
  res.status(201).json({success: true});
});

app.post('/api/issues', verifyToken, async (req, res) => {
  const issue = {
    ...req.body,
    status: 'Pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await admin.firestore().collection('issues').add(issue);
  res.status(201).json({success: true});
});

app.get('/api/devices/:id/issues', verifyToken, async (req, res) => {
  const snapshot = await admin.firestore()
    .collection('issues')
    .where('deviceId', '==', req.params.id)
    .orderBy('createdAt', 'desc')
    .get();
  const issues = snapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));
  res.json(issues);
});

app.listen(3000, () => console.log('Server running on port 3000'));
