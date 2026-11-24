# Les meves mascotes

**Memòria del projecte final**
Curs FSE552026 · Desenvolupament d'aplicacions mòbils iOS i Android amb Flutter · CIFO La Violeta
Autora: Carolina Kaechele · Docent: Eduard Carreras
Codi font: https://github.com/Caro-it/les-meves-mascotes
Data de lliurament: 16 de desembre de 2026

> ✏️ **ESBORRANY.** Les parts marcades amb ✏️ les has de completar o revisar tu. Les captures marcades amb 📷 les has de fer amb l'app final.

---

## 1. Objectiu i justificació

**Per què.** La cartilla sanitària de les mascotes és un paper que es perd, s'oblida a casa o no es consulta. Com a conseqüència, les dates de les vacunes i de les desparasitacions se'n van de cap i ens n'adonem tard.

**Per a qui.** Per a qualsevol persona que tingui un o més gossos, gats o altres animals i vulgui tenir la seva cartilla al mòbil, sempre a mà i sense perdre-la.

**Objectiu.** Fer una app mòbil senzilla que permeti registrar cada mascota amb les seves dades i apuntar-hi les vacunes i les desparasitacions amb la data de la propera dosi, i que avisi d'un cop d'ull de què està al dia, què toca aviat i què ja ha vençut.

✏️ *Si vols, afegeix aquí per què vas triar aquest tema (per exemple, si tens mascotes i t'ha passat).*

## 2. Descripció general

**Les meves mascotes** és una app feta amb Flutter (Android i iOS amb un sol codi) i amb Firebase com a backend. L'usuari crea un compte, hi afegeix les seves mascotes i, per a cadascuna, porta l'historial de vacunes i desparasitacions.

| Dada | Valor |
|---|---|
| Plataformes | Android (APK lliurada) i iOS (mateix codi; no provat per no tenir Mac) |
| Idioma | Català |
| Backend | Firebase: Authentication + Cloud Firestore (pla gratuït Spark) |
| Pantalles | 6 (A01–A06) + pantalla d'arrencada |
| Requisits mínims | Més de 4 pantalles ✅ · servidor extern (Firebase) ✅ · paleta, tipografia i aspecte propis ✅ |

**Flux principal:** Inici de sessió (A01) → Inici amb la llista de mascotes (A02) → Fitxa de la mascota (A04) → Historial (A05) → Nou registre (A06). Des de l'A02 i l'A04 també s'obre el formulari de mascota (A03).

## 3. Funcionalitats

### Imprescindibles (totes fetes)

| Codi | Funcionalitat | Estat |
|---|---|---|
| F01 | **Compte d'usuari:** crear compte, iniciar sessió, recuperar la contrasenya per correu i tancar sessió | ✅ |
| F02 | **Gestionar mascotes:** afegir, veure, editar i esborrar. Nom, espècie, raça, sexe, naixement (amb l'edat calculada), pes, xip, esterilització i foto | ✅ |
| F03 | **Registres sanitaris:** afegir, editar i esborrar vacunes i desparasitacions (internes i externes) | ✅ |
| F04 | **Historial:** registres separats en Vacunes i Desparasitacions, amb l'estat de cada un | ✅ |

**Estat de cada registre.** L'app calcula l'estat a partir de la propera dosi: **Al dia** (verd), **Toca aviat** (taronja, si falten 30 dies o menys) o **Vençut** (vermell). A l'Inici, cada mascota mostra el seu pitjor estat i quin registre és, per exemple «Vençut: Milbemax» o «Toca aviat: Polivalent (21/12)». A l'anàlisi només hi havia «Al dia» i «Toca aviat»; el «Vençut» i el nom del registre afectat es van afegir durant el desenvolupament.

### Extres

✏️ *Actualitza aquesta taula al final, segons el que hagis fet.*

| Codi | Extra | Estat |
|---|---|---|
| E07 (part) | Foto de la mascota des de la galeria | ✅ (avançat de la planificació) |
| E06 | Triar el color de la mascota | ⏳ Pendent (de moment, color automàtic) |
| E05 | Propers avisos | ⏳ Si hi ha temps |
| E02 | Llista d'avisos | ⏳ Si hi ha temps |
| E01 | Notificacions locals | ⏳ Si hi ha temps |
| E03 / E04 | Seguiment del pes / Exportar la cartilla en PDF | ❌ Fora d'abast |

## 4. Pantalles

> 📷 Per a cada pantalla, una captura de l'app real (vista de mòbil). Els dissenys de Google Stitch són a `docs/disseny/`.

### A00 · Pantalla d'arrencada
Comprova si hi ha la sessió iniciada (porta de sessió amb un `StreamBuilder`). Si n'hi ha, va a l'A02; si no, a l'A01.

### A01 · Inici de sessió / Crear compte
Una sola pantalla amb dos modes, que es canvien amb un selector «Iniciar sessió | Crear compte». En mode entrar: correu, contrasenya (amb botó per mostrar-la), «He oblidat la contrasenya» i botó Entrar. En mode crear compte: nom, correu, contrasenya i repetir-la. Els errors de Firebase es mostren en català.
📷 *Captura mode entrar* · 📷 *Captura mode crear compte*

### A02 · Inici
Salutació pel nom («Hola, Carolina»), llista de mascotes en temps real i botó flotant «Afegir mascota». Cada targeta mostra la franja de color, la foto (o una petjada), el nom, «Raça · Espècie · edat», l'etiqueta d'esterilització i l'etiqueta d'estat. Si no hi ha cap mascota, es mostra l'estat buit del disseny.
📷 *Captura amb mascotes* · 📷 *Captura de l'estat buit*

### A03 · Nova mascota / Editar mascota
El mateix formulari serveix per crear i per editar. Camps en targetes (disseny de Stitch): foto, nom*, espècie*, raça, sexe, data de naixement, pes (amb coma decimal), número de xip (15 xifres) i esterilització amb la seva data. El text de l'esterilització canvia segons el sexe (Esterilitzat / Esterilitzada).
📷 *Captura*

### A04 · Fitxa de la mascota
Capçalera de color amb la foto i una targeta a sobre amb el nom, l'espècie, la raça, l'edat calculada i la data de naixement. Targeta «Dades» amb sexe, pes, xip i esterilització. Botons Historial i Nou registre. A la barra, Editar i Esborrar (amb confirmació; s'esborren també els registres de la mascota).
📷 *Captura*

### A05 · Historial
Dues pestanyes, Vacunes i Desparasitacions, amb els registres del més recent al més antic. Cada registre mostra el tipus, la data aplicada, la propera dosi i l'etiqueta d'estat. Tocant un registre s'obre per editar-lo.
📷 *Captura amb els tres estats*

### A06 · Nou registre / Editar registre
Tipus (vacuna, desparasitació interna o externa), nom*, data d'aplicació* (no pot ser futura), propera dosi (no pot ser anterior a la data aplicada; com a màxim, d'aquí a 5 anys), veterinari i notes. En mode editar, a la barra hi ha el botó d'esborrar amb confirmació.
📷 *Captura*

## 5. Llibreries, APIs i backend

| Àmbit | Eina | Per a què |
|---|---|---|
| Framework | Flutter i Dart 3, Material 3 | Una sola base de codi per a Android i iOS |
| Backend | `firebase_core`, `firebase_auth` | Comptes d'usuari (correu i contrasenya) |
| Dades | `cloud_firestore` | Mascotes i registres al núvol, en temps real |
| Fotos | `image_picker` | Triar la foto de la galeria |
| Fotos | `path_provider` | Desar una còpia de la foto a la carpeta de l'app |
| Tipografia | Fredoka (títols) i Nunito (text) | Fitxers `.ttf` dins de l'app, funcionen sense connexió |
| Disseny | Google Stitch | Dissenys de les pantalles i del logo |

**Estructura de dades a Firestore:**

```
usuaris/{uid}                      → nom, correu, dataAlta
  └─ mascotes/{mascotaId}          → dades de la mascota
       └─ registres/{registreId}   → vacunes i desparasitacions
```

**Endpoints:** B01 crear compte · B02 iniciar sessió · B03 recuperar contrasenya · B04 tancar sessió · B05 perfil d'usuari · B06 llegir mascotes · B07 crear mascota · B08 actualitzar mascota · B09 esborrar mascota amb els seus registres · B10 llegir registres · B11 crear o actualitzar registre · B12 esborrar registre. També s'ha afegit `llegirMascota` (una sola mascota en temps real per a la fitxa), que no era a l'anàlisi.

**Seguretat.** Regles de Firestore: cada usuari només pot llegir i escriure dins de `usuaris/{uid}`, el seu propi identificador, i cal tenir la sessió iniciada. La regla `{document=**}` cobreix també les mascotes i els registres. Les regles publicades es van revisar el 24/11/2026 i coincideixen amb les del repositori (`firestore.rules`).

**Estructura del codi:**

```
lib/
  models/     usuari.dart, mascota.dart, registre.dart
  services/   auth_service.dart, usuari_service.dart, mascota_service.dart, registre_service.dart
  screens/    una pantalla per fitxer (A01–A06)
  widgets/    mascota_card, foto_mascota, camp_targeta, estat_mascota
  styles/     app_styles.dart (colors, espais, tipografia)
```

## 6. Decisions tècniques i motius

- **Firebase amb el pla gratuït Spark.** Dona comptes d'usuari i base de dades al núvol sense servidor propi i sense targeta.
- **Fotos al mòbil, no a Firebase Storage.** Storage exigeix el pla de pagament Blaze. A Firestore només es guarda la ruta de la foto. Conseqüència: a la versió web (Chrome) la foto només dura mentre l'app és oberta; a l'APK es queda desada al mòbil.
- **Patró Repositori (sessió 10B).** Les pantalles no parlen directament amb Firestore: ho fan a través dels serveis (`MascotaService`, `RegistreService`…). Els càlculs (edat, estat dels registres, text de l'esterilització) són funcions del model. Així, la mateixa lògica de l'estat la fan servir l'Historial i l'Inici.
- **Dades en temps real amb `Stream` i `StreamBuilder`.** Les llistes s'actualitzen soles quan es desa o s'esborra alguna cosa. Els `Stream` i els `Future` es creen a `initState` i no a `build`, perquè no s'obri una connexió nova cada cop que la pantalla es redibuixa (sessions 05A i 07).
- **Una sola pantalla per crear i editar** (A03 i A06), amb un paràmetre opcional: si arriba una mascota o un registre, s'edita; si no, se'n crea un de nou. Cal copiar de l'original els camps que no són al formulari, perquè `update()` escriu tots els camps.
- **Esborrar una mascota amb un `WriteBatch`.** Firestore no esborra les subcol·leccions; per això s'esborren la mascota i tots els seus registres en una sola operació atòmica (o tot o res).
- **Dates sense hora** (`DateUtils.dateOnly`) per comparar dies i no hores en calcular l'estat dels registres.
- **Estils centralitzats** a `AppStyles` i al `theme`, perquè cap color ni espai quedi escrit a les pantalles.

## 7. Canvis respecte a l'anàlisi (Activitat 2.1)

- Pantalla d'arrencada (A00) i dissenys fets amb Google Stitch, incloent-hi el logo.
- A01: selector «Iniciar sessió | Crear compte» (`SegmentedButton`) en lloc d'un botó.
- A02 sense barra inferior i amb una barra superior senzilla (títol i tancar sessió).
- Estat dels registres: s'hi afegeix «Vençut» i, a l'Inici, el nom del registre afectat.
- Esborrar un registre es fa des del formulari en mode editar (botó a la barra amb confirmació), no lliscant-lo a l'Historial.
- La foto només es tria de la galeria, sense càmera.
- No s'ha fet servir el patró d'estats de pantalla de l'activitat 1.4, perquè el `snapshot` del `StreamBuilder` ja dona els estats de càrrega, error, buit i dades.
- Endpoint nou: `llegirMascota`.

✏️ *Revisa si hi ha algun canvi més al final del projecte (per exemple, la frase de l'A01).*

## 8. Evolució futura

- Notificacions locals abans de la propera dosi (E01) i llista d'avisos (E02).
- Triar el color de cada mascota (E06) i galeria de fotos i vídeos (E07 complet).
- Seguiment del pes (E03) i exportar la cartilla en PDF per al veterinari (E04).
- Calendari i correus de Firebase en català (`flutter_localizations` i plantilles de Firebase).
- Verificar el correu en crear el compte (`sendEmailVerification`) i opció d'esborrar el compte.
- Còpia de seguretat de les fotos al núvol, si algun dia es fa una versió de pagament.
- Publicar l'app a Google Play i, més endavant, a l'App Store.

## 9. Reflexió personal

> ✏️ **Aquesta part l'has d'escriure tu, amb les teves paraules.** Sota de cada pregunta tens dades del teu procés per ajudar-te a recordar, no un text per copiar.

**Impressió general del projecte.**
✏️

**Dificultats i com les vaig resoldre.**
*Per recordar:* el login amb `invalid-credential` (la consola de Firebase no mostra les contrasenyes); els salts de línia CRLF/LF a Windows; les comandes de PowerShell enganxades juntes; codi enganxat al lloc equivocat (un servei dins d'una pantalla, funcions dins d'una altra funció) i parèntesis de més; els imports que faltaven; entrar amb un altre compte i pensar que les mascotes havien desaparegut; un document «fantasma» a Firestore en esborrar una mascota sense els seus registres; la trampa d'`update()`, que esborra els camps que no hi són.
✏️

**Canvis respecte a l'anàlisi i per què.** (Vegeu l'apartat 7.)
✏️

**Què m'ha aportat.**
✏️

**Com m'ajudarà en el meu futur professional.**
✏️

---

### Annex · Compte de prova

✏️ *Correu i contrasenya del compte de prova amb dades (el profe ho demana). Crea'l al final des de l'app.*

| Correu | Contrasenya |
|---|---|
| ✏️ | ✏️ |
