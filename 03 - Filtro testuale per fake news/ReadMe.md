# Filtro testuale per fake news

Il progetto è stato realizzato al termine del corso di Natural Language Processing nel Master di Data Analyst di ProfessionAI ed è stato revisionato nel novembre 2024. Lo scopo del progetto era costruire un modello di classificazione testuale che rilevasse le fake news a partire dal titolo e dal testo della notizia.

## Specifiche

Simulando una richiesta da parte del governo americano nella lotta alla disinformazione, lo scopo del progetto era costruire un modello di classificazione in grado di distinguere le notizie vere da quelle false con l'obiettivo di implementare un plug-in nei principali browser web. Il progetto è stato realizzato a partire da un file ZIP contenente due file CSV, uno con le notizie vere e l'altro con le notizie false, e ha seguito la costruzione del modello dall'analisi esplorativa dei dati fino alla sua esportazione.

Al notebook relativo al progetto si aggiungono i seguenti file, salvati nella cartella *output_files*:

- Il file *cleaner.pickle* con la funzione per la pulizia del testo;
- Il file *vectorizer.pickle* per la vettorizzazione;
- Il file *classifier.pickle* con il modello di classificazione;
- Il file *predictor.pickle* con la funzione per classificare le notizie.

## Tecnologie utilizzate

🐍 Python per il codice

🐼 Pandas per l'importazione e la gestione dei dati

🤖 Scikit-Learn per i modelli

📔 Jupyter Notebook per il progetto e la revisione
