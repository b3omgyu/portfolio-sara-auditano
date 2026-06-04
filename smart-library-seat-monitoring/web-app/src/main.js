import './style.css';

import { initializeApp } from "firebase/app";
import { getDatabase, ref, onValue } from "firebase/database";

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

const app = document.querySelector('#app');

function mostraPosti(posti) {
  const listaPosti = Object.entries(posti).map(([nome, info]) => {
    const stato = info.stato || (info.occupato ? "occupato" : "libero");

    return {
      nome,
      stato,
      occupato: info.occupato,
      inVerifica: info.inVerifica || false
    };
  });

  const liberi = listaPosti.filter((posto) => posto.stato === "libero").length;
  const occupati = listaPosti.filter((posto) => posto.stato === "occupato").length;
  const inVerifica = listaPosti.filter((posto) => posto.stato === "verifica").length;

  const cardsPosti = listaPosti.map((posto) => {
    let testo = "Libero";
    let classe = "libero";

    if (posto.stato === "occupato") {
      testo = "Occupato";
      classe = "occupato";
    }

    if (posto.stato === "verifica") {
      testo = "In verifica";
      classe = "verifica";
    }

    return `
      <div class="posto ${classe}">
        <h2>${posto.nome}</h2>
        <p>${testo}</p>
      </div>
    `;
  }).join('');

  app.innerHTML = `
    <main class="contenuto">
      <header class="header">
        <div class="logo-box">
          <img src="/Logo-uniparthenope.gif" alt="Logo Università degli Studi di Napoli Parthenope">
        </div>

        <h1>Biblioteca del Polo di Ingegneria e Scienze Tecnologiche</h1>

        <p class="sottotitolo">
          Sistema intelligente per la visualizzazione dei posti liberi e occupati
        </p>

        <p class="indirizzo">
          Centro Direzionale, Isola C4 - 80133 Napoli
        </p>
      </header>

      <section class="riepilogo">
        <div>
          <strong>${liberi}</strong>
          <span>Liberi</span>
        </div>

        <div>
          <strong>${occupati}</strong>
          <span>Occupati</span>
        </div>

        <div>
          <strong>${inVerifica}</strong>
          <span>In verifica</span>
        </div>
      </section>

      <section class="griglia">
        ${cardsPosti}
      </section>

      <section class="legenda">
        <h3>Legenda stati</h3>

        <div class="legenda-righe">
          <div class="legenda-card">
            <div class="legenda-titolo">
              <span class="pallino pallino-libero"></span>
              <strong>Libero</strong>
            </div>
            <p>Posto disponibile.</p>
          </div>

          <div class="legenda-card">
            <div class="legenda-titolo">
              <span class="pallino pallino-occupato"></span>
              <strong>Occupato</strong>
            </div>
            <p>Posto attualmente occupato.</p>
          </div>

          <div class="legenda-card legenda-card-verifica">
            <div class="legenda-titolo">
              <span class="pallino pallino-verifica"></span>
              <strong>In verifica</strong>
            </div>
            <p>Possibile assenza temporanea: il sistema attende 30 secondi prima di dichiarare il posto libero.</p>
          </div>
        </div>
      </section>
    </main>

    <footer class="footer-autori">
      Realizzato da <strong>Sara Auditano</strong>, <strong>Federica Capuano</strong> e <strong>Ciro Pazzi</strong>
    </footer>
  `;
}

const postiRef = ref(database, 'posti');

onValue(postiRef, (snapshot) => {
  const dati = snapshot.val();

  if (dati) {
    mostraPosti(dati);
  } else {
    app.innerHTML = `
      <main class="contenuto">
        <header class="header">
          <div class="logo-box">
            <img src="/Logo-uniparthenope.gif" alt="Logo Università degli Studi di Napoli Parthenope">
          </div>

          <h1>Biblioteca del Polo di Ingegneria e Scienze Tecnologiche</h1>
          <p class="sottotitolo">Nessun dato trovato nel database.</p>
        </header>
      </main>

      <footer class="footer-autori">
        Realizzato da <strong>Sara Auditano</strong>, <strong>Federica Capuano</strong> e <strong>Ciro Pazzi</strong>
      </footer>
    `;
  }
});