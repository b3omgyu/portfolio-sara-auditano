import { SerialPort } from 'serialport';
import { initializeApp } from 'firebase/app';
import { getDatabase, ref, update } from 'firebase/database';

const firebaseConfig = {
  apiKey: "AIzaSyDRoIcVuSi2Mb3ECEqFqnrZ2Woodv3RWqU",
  authDomain: "biblioteca-posti.firebaseapp.com",
  databaseURL: "https://biblioteca-posti-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "biblioteca-posti",
  storageBucket: "biblioteca-posti.firebasestorage.app",
  messagingSenderId: "454418881617",
  appId: "1:454418881617:web:a872866622c87f07526c70"
};

const appFirebase = initializeApp(firebaseConfig);
const database = getDatabase(appFirebase);

const POSTO_ID = "A1";
const PORTA = "COM5";
const BAUD_RATE = 9600;
const TEMPO_VERIFICA_MS = 30 * 1000;

let timerVerificaLibero = null;
let ultimoStatoSensore = "sconosciuto";
let statoFirebase = "sconosciuto";
let buffer = "";

console.log("====================================");
console.log(`BRIDGE BLUETOOTH - POSTO ${POSTO_ID}`);
console.log("====================================");

const port = new SerialPort({
  path: PORTA,
  baudRate: BAUD_RATE,
  autoOpen: false
});

port.open((err) => {
  if (err) {
    console.log(`${PORTA} non aperta: ${err.message}`);
    return;
  }

  console.log(`Bluetooth collegato su ${PORTA}`);
  console.log(`La porta ${PORTA} aggiorna Firebase su posti/${POSTO_ID}`);
});

port.on('data', (data) => {
  buffer += data.toString();

  if (buffer.includes('\n')) {
    const righe = buffer.split('\n');
    buffer = righe.pop();

    righe.forEach((riga) => {
      const messaggio = riga.trim();

      if (!messaggio) return;

      gestisciMessaggio(messaggio);
    });
  }
});

port.on('error', (err) => {
  console.error(`Errore su ${PORTA}:`, err.message);
});

function gestisciMessaggio(messaggio) {
  console.log(`[${POSTO_ID}] Ricevuto: ${messaggio}`);

  if (messaggio.includes('POSTO OCCUPATO')) {
    ultimoStatoSensore = "occupato";
    mettiOccupato();

  } else if (
    messaggio.includes('POSTO LIBERO') ||
    messaggio.includes('Misura non valida') ||
    messaggio.includes('fuori range')
  ) {
    ultimoStatoSensore = "libero";
    mettiInVerifica();

  } else {
    console.log(`[${POSTO_ID}] Messaggio ignorato`);
  }
}

function mettiOccupato() {
  if (timerVerificaLibero !== null) {
    clearTimeout(timerVerificaLibero);
    timerVerificaLibero = null;
  }

  if (statoFirebase !== "occupato") {
    statoFirebase = "occupato";

    update(ref(database, `posti/${POSTO_ID}`), {
      stato: "occupato",
      occupato: true,
      inVerifica: false,
      ultimoAggiornamento: Date.now()
    });

    console.log(`Firebase aggiornato: ${POSTO_ID} = occupato`);
  }
}

function mettiInVerifica() {
  if (statoFirebase === "libero") return;

  if (statoFirebase !== "verifica") {
    statoFirebase = "verifica";

    update(ref(database, `posti/${POSTO_ID}`), {
      stato: "verifica",
      occupato: true,
      inVerifica: true,
      ultimoAggiornamento: Date.now()
    });

    console.log(`Firebase aggiornato: ${POSTO_ID} = in verifica`);
  }

  if (timerVerificaLibero === null) {
    timerVerificaLibero = setTimeout(() => {
      timerVerificaLibero = null;

      if (ultimoStatoSensore === "libero") {
        statoFirebase = "libero";

        update(ref(database, `posti/${POSTO_ID}`), {
          stato: "libero",
          occupato: false,
          inVerifica: false,
          ultimoAggiornamento: Date.now()
        });

        console.log(`Firebase aggiornato: ${POSTO_ID} = libero dopo verifica`);
      }
    }, TEMPO_VERIFICA_MS);
  }
}