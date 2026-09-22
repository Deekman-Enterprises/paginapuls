# Paginapuls — live zetten (GitHub + Supabase)

Dit is de "echte" versie van de Paginapuls-demo: inloggen gaat nu via een echte
eenmalige code die naar het echte e-mailadres van de klant/collega wordt
gestuurd, en klant- en teamaccounts staan in een echte database in plaats van
in de browser. De website-cijfers (bezoekers, SEO-score, zoekwoorden) zijn nog
steeds gegenereerde voorbeelddata — dat is een aparte, latere stap (koppeling
met Google Analytics / Search Console per klantwebsite).

Twee onderdelen, allebei gratis te starten:

1. **Supabase** — de database + login + e-mailverzending (de "backend").
2. **GitHub Pages** — hosting van de website zelf (de "frontend"): alleen
   statische bestanden, dus GitHub Pages is hiervoor genoeg. Er is geen aparte
   server nodig.

Reken op zo'n 15–20 minuten voor de eerste keer.

## Stap 1 — Supabase-project aanmaken

1. Ga naar [supabase.com](https://supabase.com) en maak een gratis account
   (kan met je GitHub-account).
2. Klik **New project**. Kies een naam (bijv. "paginapuls"), een wachtwoord
   voor de database (bewaar dit ergens veilig, je hebt het straks niet meer
   nodig) en een regio dicht bij je klanten (bijv. Frankfurt/West-Europa).
3. Wacht tot het project klaar is (ca. 1-2 minuten).

## Stap 2 — Database + beveiliging aanmaken

1. Open in je Supabase-project links het menu **SQL Editor** → **New query**.
2. Open het bestand `supabase/schema.sql` uit deze map, kopieer de hele
   inhoud, en plak die in de SQL Editor.
3. Pas **vóór** je op Run klikt de regel met `'thomasdeekman@gmail.com'`
   eventueel aan naar het e-mailadres waarmee jij zelf als bureau wilt
   inloggen (of laat 'm staan en wijzig het later gewoon via **Table
   editor** → `team_members`).
4. Klik **Run**. Dit maakt twee tabellen (`sites`, `team_members`), zet de
   beveiliging (Row Level Security) aan, en zet er dezelfde 5 voorbeeldklanten
   en 3 teamleden in als in de demo.

Wat deze beveiliging doet: een teamlid (iemand in `team_members`) mag alles
zien en beheren; een klant mag alleen de rij van zijn eigen website zien. Dit
wordt afgedwongen door de database zelf (niet door de website-code) — dus ook
niet te omzeilen via de browserconsole.

## Stap 3 — E-mail-login instellen

Supabase stuurt de eenmalige inlogcodes standaard al via hun eigen e-mail­systeem — voor
testen (een paar keer per uur) werkt dit meteen, zonder verdere instellingen.

**Voor echt gebruik met klanten** moet je een eigen e-mailafzender koppelen,
anders loop je al snel tegen het (lage) verzendlimiet van de gratis test-e-mail
aan en belanden mails soms in spam:

1. In Supabase: **Authentication** → **Providers** → **Email**. Zorg dat
   "Enable email provider" aan staat en "Confirm email" bij voorkeur **uit**
   staat (die is niet nodig voor deze inlogflow).
2. **Authentication** → **Emails** → **SMTP Settings**: koppel een eigen
   e-mailafzender. Een gratis/goedkope optie die eenvoudig te koppelen is:
   [Resend](https://resend.com) (3.000 e-mails/maand gratis) of
   [Postmark](https://postmarkapp.com). Je vult daar host/poort/gebruikersnaam/
   wachtwoord van die dienst in.
3. Optioneel: pas onder **Authentication** → **Emails** → **Templates** →
   "Magic Link" de e-mailtekst aan naar iets als "Je Paginapuls-inlogcode"
   (Supabase gebruikt hetzelfde sjabloon voor de 6-cijferige code).

Dit mag je ook later doen — inloggen werkt al met de standaard Supabase-mail,
alleen met een laag verzendlimiet.

## Stap 4 — Project-URL en sleutel invullen

1. In Supabase: **Project Settings** (tandwiel) → **API**.
2. Kopieer **Project URL** en de **anon / public** key (niet de
   `service_role`-key!).
3. Open `supabase-config.js` in deze map en vul beide waarden in:

   ```js
   window.SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   window.SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```

De anon-key is bedoeld om openbaar te zijn (ook zichtbaar voor iedereen die de
site bezoekt) — dat is normaal voor Supabase. De echte beveiliging zit in de
database-policies uit stap 2, niet in het verbergen van deze sleutel.

## Stap 5 — Naar GitHub

1. Maak een gratis account op [github.com](https://github.com) als je die nog
   niet hebt.
2. Maak een nieuwe **repository** (rechtsboven **+** → **New repository**).
   Naam mag alles zijn, bijv. `paginapuls`. Zet 'm gerust op **Public** — er
   staan geen geheimen in (zie stap 4).
3. Upload de inhoud van deze map (`index.html`, `supabase-config.js`, en de
   map `supabase/`) naar die repository. Twee manieren:
   - **Zonder terminal:** open de nieuwe repository op GitHub.com, klik
     **Add file** → **Upload files**, sleep alle bestanden erin, en klik
     **Commit changes**.
   - **Met git:**
     ```bash
     cd paginapuls-live
     git init
     git add .
     git commit -m "Eerste versie van Paginapuls live"
     git branch -M main
     git remote add origin https://github.com/<jouw-gebruikersnaam>/paginapuls.git
     git push -u origin main
     ```

## Stap 6 — GitHub Pages aanzetten

1. Ga in je repository naar **Settings** → **Pages**.
2. Bij **Source** kies je **Deploy from a branch**, branch **main**, map
   **/ (root)**. Klik **Save**.
3. Na ongeveer een minuut staat je site live op
   `https://<jouw-gebruikersnaam>.github.io/paginapuls/`.

Wil je een eigen domein (bijv. `app.deekmanenterprises.nl`)? Dat kan ook via
GitHub Pages — zet dan bij **Settings → Pages → Custom domain** je domeinnaam,
en voeg bij je domeinregistrar een CNAME-record toe dat naar
`<jouw-gebruikersnaam>.github.io` wijst.

## Testen

1. Open je live URL.
2. Vul het e-mailadres in dat je in stap 2 bij `team_members` hebt gezet (of
   `thomasdeekman@gmail.com` als je dat niet hebt aangepast) en klik **Stuur
   inlogcode**.
3. Check die inbox voor de 6-cijferige code, vul 'm in, en je zit in het
   bureau-dashboard.
4. Voeg via **Instellingen** een test-klantwebsite toe met je eigen (tweede)
   e-mailadres, log uit, en log in met dat adres — je zou nu alléén het
   klantportaal van die ene website moeten zien.

## Wat is er nog "demo" en wat is nu echt?

- **Echt:** inloggen (echte e-mail + eenmalige code), wie welk account mag
  zien (database-beveiliging), en het beheer van klant-/teamaccounts
  (Instellingen) — dit staat allemaal in jouw eigen Supabase-database.
- **Nog demo:** de bezoekcijfers, SEO-score, zoekwoorden en
  concurrentievergelijking per website. Die worden nog gegenereerd (consistent
  per website, verandert niet bij elke refresh) in plaats van uit een echte
  bron te komen. Voor échte cijfers is een volgende stap nodig: per
  klantwebsite koppelen met Google Analytics 4 en/of Google Search Console
  (en eventueel een tool als Ahrefs/SEMrush voor concurrentiedata). Dat is een
  aparte, grotere uitbreiding — laat het weten als je die ook wilt.

## Iets werkt niet?

- **"Deze site is nog niet gekoppeld aan een database"** op het inlogscherm:
  `supabase-config.js` is nog niet (goed) ingevuld — zie stap 4.
- **Geen e-mail met code ontvangen:** kijk in spam, en check bij een hoop
  testpogingen achter elkaar of je niet tegen het gratis verzendlimiet aanloopt
  (zie stap 3 — koppel dan een eigen SMTP-afzender).
- **"Dit e-mailadres is niet gekoppeld aan een bureau- of klantaccount":** dat
  adres staat nog niet in `team_members` of `sites` in je database — voeg het
  toe via **Instellingen** (als bureau) of direct in Supabase's Table editor.
