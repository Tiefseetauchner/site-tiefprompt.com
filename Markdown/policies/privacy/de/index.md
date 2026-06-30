---
title: Datenschutzerklärung
nav_label: Deutsch
description: Datenschutzerklärung für TiefPrompt.
---

# Datenschutzerklärung TiefPrompt

**Stand:** 5. Mai 2026
**Version:** 1.0

## Zusammenfassung

TiefPrompt ist eine Teleprompter-Anwendung. Sie erhebt, übermittelt und speichert keine personenbezogenen Daten auf einem vom Entwickler betriebenen Server. Alles, was Sie in TiefPrompt eingeben — Skripte, Einstellungen, Profile, Tastenbelegungen — verbleibt auf Ihrem Gerät. Der Entwickler hat darauf keinen Zugriff, kann diese Daten nicht einsehen und nicht wiederherstellen.

Die einzige Netzwerkkommunikation, die TiefPrompt durchführt, ist die Validierung von In-App-Käufen im Freemium-Build, die durch Apple bzw. Google abgewickelt wird (siehe Abschnitt 7). Der FOSS-Build führt überhaupt keine Netzwerkkommunikation durch.

Diese Erklärung beschreibt die aktuelle Version von TiefPrompt. Künftige Versionen können optionale serverbasierte Funktionen einführen (etwa die geräteübergreifende Synchronisation oder die Fernsteuerung). Diese Funktionen werden ausschließlich auf opt-in-Basis verfügbar sein, ein Benutzerkonto erfordern und Sie vor jeder Datenübertragung um ausdrückliche Zustimmung zu einer aktualisierten Datenschutzerklärung ersuchen. Solange Sie sich nicht aktiv dafür entscheiden, ändert sich für Sie an dieser Erklärung nichts.

## 1. Begriffsbestimmungen

Diese Datenschutzerklärung unterscheidet zwischen zwei Builds von TiefPrompt:

- **Freemium-Build** — der Build, der ausschließlich über den Apple App Store (iOS und macOS) sowie über den Google Play Store (Android) vertrieben wird. Dieser Build enthält In-App-Kauf-Funktionalität und führt ausschließlich zur Validierung von In-App-Käufen Netzwerkkommunikation durch, und zwar auf Ihrem Gerät.
- **FOSS-Build** — der freie und quelloffene Build, der über F-Droid (Android), https://lukechriswalker.at sowie GitHub Releases (Windows, Linux, macOS, Android) vertrieben wird. Dieser Build enthält keine In-App-Kauf-Funktionalität und führt keinerlei Netzwerkkommunikation durch.

Verweist diese Erklärung ohne weitere Spezifikation auf „TiefPrompt", so gilt die jeweilige Aussage für beide Builds. Gilt eine Aussage nur für einen der Builds, so wird dieser ausdrücklich genannt.

## 2. Verantwortlicher

TiefPrompt wird entwickelt und herausgegeben von:

**Lena Tauchner**, Einzelunternehmerin
Gewerbe für Softwareentwicklung, registriert in Österreich
Kontakt: admin@lukechriswalker.at

Die vollständigen Geschäftsdaten (Impressum) sind unter https://lukechriswalker.at abrufbar.

Für sämtliche datenschutzbezogenen Anfragen — einschließlich der Geltendmachung von Rechten nach der DSGVO oder anderen anwendbaren Rechtsvorschriften — ist die oben genannte E-Mail-Adresse die zuständige Kontaktstelle.

## 3. Anwendungsbereich dieser Erklärung

Diese Datenschutzerklärung gilt für die Anwendung TiefPrompt auf allen nachstehend angeführten Plattformen und über alle nachstehend angeführten Vertriebskanäle:

| Build | Plattform | Vertriebskanal |
|-------|-----------|----------------|
| Freemium | iOS | Apple App Store |
| Freemium | macOS | Mac App Store |
| Freemium | Android | Google Play |
| FOSS | Android | F-Droid, https://lukechriswalker.at, GitHub Releases |
| FOSS | Windows | https://lukechriswalker.at, GitHub Releases |
| FOSS | macOS | https://lukechriswalker.at, GitHub Releases |
| FOSS | Linux | https://lukechriswalker.at, GitHub Releases |

Sie gilt nicht für die Websites selbst (für diese gelten gegebenenfalls eigene Datenschutzhinweise) oder für Drittdienste, die Sie unabhängig davon neben TiefPrompt verwenden.

## 4. Daten, die nicht erhoben werden

Der Entwickler erhebt, empfängt, speichert und verarbeitet insbesondere keine der folgenden Daten:

- den Inhalt Ihrer Skripte, einschließlich aller persönlichen, beruflichen oder sensiblen Texte, die Sie eingeben oder importieren
- Ihre Einstellungen, Profile oder Tastenbelegungen
- Ihren Namen, Ihre E-Mail-Adresse, Ihre Telefonnummer oder sonstige Identifikatoren
- Ihre IP-Adresse oder Ihren ungefähren Standort
- Gerätekennungen, Werbe-IDs sowie jegliche Analyse- oder Telemetriedaten
- Absturzberichte oder Diagnosedaten
- Nutzungsmuster, Sitzungsdauer, Funktionsinteraktionen oder sonstige Verhaltensdaten

In keinem Build von TiefPrompt sind auf irgendeiner Plattform Drittanbieter-SDKs für Analyse, Werbung, Tracking oder Absturzberichte eingebunden.

## 5. Lokal auf Ihrem Gerät gespeicherte Daten

TiefPrompt speichert ausschließlich auf Ihrem Gerät folgende Daten:

- Skripte, die Sie in der App erstellen oder importieren
- Anwendungseinstellungen und Benutzervoreinstellungen
- von Ihnen konfigurierte Profile und Tastenbelegungen
- im Freemium-Build: einen lokalen Eintrag über Ihre In-App-Kauf-Berechtigung (siehe Abschnitt 7)

Diese Daten werden über die standardmäßigen Anwendungsspeichermechanismen Ihres Betriebssystems abgelegt. Sie sind ausschließlich für TiefPrompt sowie — entsprechend den Zugriffskontrollen Ihres Betriebssystems — für Sie zugänglich. Die App übermittelt diese Daten nicht. Sie können sämtliche lokal gespeicherten Daten entfernen, indem Sie TiefPrompt deinstallieren oder die Anwendungsdatenverwaltung Ihres Betriebssystems verwenden.

## 6. Von der App angeforderte Berechtigungen

TiefPrompt fordert die folgenden Betriebssystemberechtigungen an. Jede Berechtigung ist an eine bestimmte Funktion gebunden, wird ausschließlich im Moment der Inanspruchnahme dieser Funktion verwendet und ausschließlich auf Ihrem Gerät verarbeitet:

- **Speicher- bzw. Dateizugriff (iOS, Android):** zum Importieren von Skripten aus dem Speicher Ihres Geräts sowie zum Exportieren von Ihnen verfasster Skripte.

Die Desktop-Builds (Windows, Linux, macOS) fordern darüber hinaus keine Berechtigungen an, die über jene hinausgehen, die für den Betrieb einer üblichen Anwendung im Benutzerkontext implizit sind.

Über keine dieser Berechtigungen abgerufene Daten werden an den Entwickler oder an Dritte übermittelt.

## 7. In-App-Käufe (nur Freemium-Build)

Der Freemium-Build von TiefPrompt bietet einen einmaligen Freischaltkauf an. Die Abwicklung von Käufen erfolgt vollständig durch Apple (App Store, Mac App Store) bzw. Google (Google Play); der Entwickler erhält, sieht und speichert weder Ihre Zahlungsdaten noch Ihren Namen, Ihre E-Mail-Adresse oder sonstige mit dem Kauf verbundene personenbezogene Angaben.

Apple bzw. Google stellen der App jeweils einen kryptographischen Beleg darüber bereit, dass ein Kauf erfolgt ist. TiefPrompt validiert diesen Beleg **auf Ihrem Gerät** mittels StoreKit (iOS, macOS) bzw. der Google Play Billing Library (Android). Der Beleg wird nicht an einen vom Entwickler betriebenen Server übermittelt. Am Kauf- und Validierungsvorgang ist kein vom Entwickler betriebener Server beteiligt.

Die Verarbeitung Ihrer Zahlungsdaten durch Apple und Google selbst richtet sich nach deren jeweiligen Datenschutzerklärungen:

- Apple: https://www.apple.com/legal/privacy/
- Google: https://policies.google.com/privacy

Der FOSS-Build enthält keine In-App-Kauf-Funktionalität und führt zu diesem oder einem anderen Zweck keine Netzwerkkommunikation durch.

## 8. Dritte

In TiefPrompt erheben, übermitteln und empfangen keinerlei Drittanbieter-SDKs, -Dienste, -Bibliotheken oder -Integrationen Daten über Sie. Am Betrieb der App sind ausschließlich die folgenden Dritten beteiligt:

- **Apple** und **Google** in ihrer Eigenschaft als App-Store- und Abrechnungsanbieter für den Freemium-Build, nach deren oben verlinkten Datenschutzerklärungen.
- **F-Droid** als Vertriebskanal für den FOSS-Android-Build, nach den eigenen Datenschutzbestimmungen unter https://f-droid.org/.
- **GitHub** als Vertriebskanal für FOSS-Veröffentlichungen, nach den eigenen Datenschutzbestimmungen unter https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement.

Der Entwickler übermittelt diesen Stellen keine Daten, weil der Entwickler keine Daten erhebt.

## 9. Datenschutz für Kinder

TiefPrompt richtet sich nicht an Kinder und erhebt wissentlich keine Daten von irgendjemandem, auch nicht von Kindern. Setzt das anwendbare nationale oder regionale Recht ein digitales Mindestalter für die Einwilligung fest, so ist aufgrund der nullsammelnden Konzeption der App für die aktuelle Version kein Einwilligungsmechanismus durch Erziehungsberechtigte erforderlich.

## 10. Ihre Datenschutzrechte

Befinden Sie sich in der Europäischen Union, im Europäischen Wirtschaftsraum oder im Vereinigten Königreich, so stehen Ihnen das Recht auf Auskunft, auf Berichtigung, auf Löschung, auf Einschränkung der Verarbeitung, auf Datenübertragbarkeit und auf Widerspruch zu, ebenso das Recht, nicht einer ausschließlich auf einer automatisierten Verarbeitung beruhenden Entscheidung unterworfen zu werden, jeweils nach Maßgabe der Artikel 15 bis 22 DSGVO (sowie der entsprechenden Bestimmungen des Rechts des Vereinigten Königreichs). Darüber hinaus haben Sie das Recht, gemäß Artikel 77 DSGVO Beschwerde bei einer Aufsichtsbehörde einzulegen.

Sind Sie in einem US-Bundesstaat mit einem umfassenden Datenschutzgesetz wohnhaft, so stehen Ihnen die nach dem Recht Ihres Bundesstaates gewährten Rechte zu, die etwa die Rechte auf Auskunft, Löschung, Berichtigung, auf Widerspruch gegen den Verkauf oder die Weitergabe personenbezogener Daten, auf Beschränkung der Verwendung sensibler personenbezogener Daten sowie auf Nichtbenachteiligung wegen der Ausübung dieser Rechte umfassen können. Der Entwickler verkauft, teilt oder gibt keine personenbezogenen Daten anderweitig weiter und bietet auch keinen finanziellen Anreiz im Austausch für personenbezogene Daten.

Da der Entwickler keine personenbezogenen Daten über Sie erhebt oder vorhält, gibt es in der Praxis nichts, worüber Auskunft erteilt, was berichtigt, gelöscht, eingeschränkt, übertragen, beworben oder dem widersprochen werden könnte. Die Geltendmachung eines dieser Rechte führt typischerweise zu einer Bestätigung des Entwicklers, dass keine derartigen Daten vorhanden sind.

### Wie können Sie Ihren Antrag einbringen?

Sie können Ihren Antrag per E-Mail an **admin@lukechriswalker.at** richten. Bitte fassen Sie Ihren Antrag so konkret wie möglich. Der Entwickler kann gegebenenfalls weitere Angaben zu Ihrer Identität verlangen, jedoch nur insoweit, als dies erforderlich ist, um sicherzustellen, dass Informationen ausschließlich an die betroffene Person selbst übermittelt werden.

### Innerhalb welcher Frist erfolgt die Beantwortung?

Der Entwickler wird Ihren Antrag unverzüglich, jedenfalls aber innerhalb eines Monats nach Eingang beantworten. Diese Frist kann um weitere zwei Monate verlängert werden, soweit dies unter Berücksichtigung der Komplexität und der Anzahl der Anträge erforderlich ist; der Entwickler wird Sie in diesem Fall innerhalb eines Monats nach Eingang des Antrags über die Fristverlängerung sowie über deren Gründe unterrichten.

### Wo können Sie Beschwerde einlegen?

Sie können Beschwerde bei der Aufsichtsbehörde Ihres Mitgliedstaats des gewöhnlichen Aufenthalts einlegen. In Österreich ist die zuständige Aufsichtsbehörde:

**Österreichische Datenschutzbehörde**
Barichgasse 40-42, 1030 Wien, Österreich
Telefon: +43 1 52 152-0
E-Mail: dsb@dsb.gv.at
Web: https://www.dsb.gv.at

## 11. Speicherdauer

Der Entwickler bewahrt keine personenbezogenen Daten auf, da keine erhoben werden. Lokal auf Ihrem Gerät gespeicherte Daten verbleiben dort, bis Sie sie löschen oder die App deinstallieren.

Belege über In-App-Käufe im Freemium-Build werden von Apple und Google nach deren eigenen Aufbewahrungsrichtlinien aufbewahrt.

## 12. Internationale Datenübermittlungen

Es finden keine internationalen Datenübermittlungen statt, da keine Daten erhoben oder an einen vom Entwickler betriebenen Server übermittelt werden. Etwaige Übermittlungen, die durch Apple, Google, F-Droid oder GitHub im Zusammenhang mit dem Vertrieb der App oder mit In-App-Käufen erfolgen, richten sich nach deren jeweiligen Datenschutzerklärungen.

## 13. Sicherheit

Da keine Daten Ihr Gerät verlassen, wird die Sicherheit Ihrer TiefPrompt-Daten durch die Sicherheit Ihres Geräts und Ihres Betriebssystems bestimmt. TiefPrompt verwendet die standardmäßigen, vom Betriebssystem bereitgestellten Anwendungsspeichermechanismen und implementiert keinen eigenen Netzwerktransport, da kein Netzwerktransport durchgeführt wird.

Bei der Validierung von In-App-Kauf-Belegen im Freemium-Build werden die kryptographischen Vorgänge durch die jeweiligen Erstanbieter-Bibliotheken von Apple bzw. Google auf Ihrem Gerät ausgeführt.

## 14. Änderungen dieser Datenschutzerklärung

Der Entwickler kann diese Erklärung aktualisieren, um Änderungen an der Anwendung, am anwendbaren Recht oder am Geschäftsbetrieb Rechnung zu tragen. Bei wesentlichen Änderungen — insbesondere wenn optionale serverbasierte Funktionen (etwa Synchronisation oder Fernsteuerung) eingeführt werden — wird Ihnen die aktualisierte Erklärung in der App vorgelegt; vor der Anwendung jeder neuen Verarbeitungstätigkeit auf Sie wird Ihre ausdrückliche Zustimmung eingeholt. Verweigern Sie die Zustimmung, so steht Ihnen die neue Funktion schlicht nicht zur Verfügung; die bestehende offline-Funktionalität von TiefPrompt bleibt wie in dieser Erklärung beschrieben weiterhin uneingeschränkt nutzbar.

Nicht-wesentliche Aktualisierungen (etwa Klarstellungen, Korrekturen oder Änderungen der Kontaktdaten) werden durch Aktualisierung des Datums und der Versionsnummer am Beginn dieses Dokuments kenntlich gemacht. Die maßgebliche aktuelle Fassung ist stets jene, die unter [https://tiefprompt.com/policies/privacy/de](https://tiefprompt.com/policies/privacy/de) veröffentlicht ist.

## 15. Anwendbares Recht und Gerichtsstand

Diese Erklärung unterliegt österreichischem Recht unter Ausschluss der Verweisungsnormen des internationalen Privatrechts. Für sämtliche aus oder im Zusammenhang mit dieser Erklärung entstehenden Streitigkeiten sind ausschließlich die sachlich zuständigen Gerichte in Wien zuständig, vorbehaltlich zwingender verbraucherschutzrechtlicher Bestimmungen des Rechts Ihres gewöhnlichen Aufenthaltsstaats, von denen vertraglich nicht abgewichen werden darf.

Diese Klausel berührt nicht Ihr Recht als betroffene Person nach der DSGVO, Beschwerde bei der Aufsichtsbehörde Ihres Mitgliedstaats des gewöhnlichen Aufenthalts einzulegen.

## 16. Kontakt

Bei Fragen zu dieser Erklärung oder zu Datenschutzangelegenheiten allgemein:

**admin@lukechriswalker.at**
