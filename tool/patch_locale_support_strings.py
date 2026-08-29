#!/usr/bin/env python3
"""Patch all non-en ARBs with localized support-ad + font-download strings."""

from __future__ import annotations

import json
from pathlib import Path

L10N = Path(__file__).resolve().parent.parent / "lib" / "l10n"

# Shared meaning: interstitial support ad (no reward) + font download UX.
TRANSLATIONS: dict[str, dict[str, str]] = {
    "ar": {
        "supportAdReady": "إعلان الفيديو جاهز - اضغط للمشاهدة",
        "supportAdUnavailable": "جاري تحميل الإعلان... حاول مرة أخرى قريباً",
        "supportLoadingAd": "جاري تحميل الإعلان...",
        "settingsLoadingAd": "جاري تحميل الإعلان...",
        "supportWatchVideoTitle": "شاهد فيديو إعلانياً",
        "settingsWatchAdToSupport": "شاهد إعلاناً للدعم",
        "settingsThanksForSupport": "شكراً لدعمك لتطبيق Learn Anything!",
        "supportFaqAdsAnswer": "لا إعلانات ملء الشاشة إجبارية. قد يظهر شريط صغير في نتائج الاختبار. يمكنك اختيار مشاهدة إعلان من الإعدادات أو الدعم.",
        "languageFontDownloadTitle": "تنزيل الخطوط؟",
        "languageFontDownloadBody": "هذه اللغة تحتاج خطوطاً إضافية لعرض النص بوضوح (بضعة ميغابايت). التنزيل الآن؟",
        "languageFontDownloadAction": "تنزيل",
        "languageFontDownloadFailed": "تعذر تنزيل الخطوط. تحقق من الاتصال وحاول مرة أخرى.",
        "languageFontDownloadSuccess": "الخطوط جاهزة لهذه اللغة.",
        "languageFontDownloadProgress": "جاري تنزيل الخطوط...",
    },
    "hi": {
        "supportAdReady": "वीडियो विज्ञापन तैयार है - देखने के लिए टैप करें",
        "supportAdUnavailable": "विज्ञापन लोड हो रहा है... थोड़ी देर बाद फिर कोशिश करें",
        "supportLoadingAd": "विज्ञापन लोड हो रहा है...",
        "settingsLoadingAd": "विज्ञापन लोड हो रहा है...",
        "supportWatchVideoTitle": "प्रायोजित वीडियो देखें",
        "settingsWatchAdToSupport": "समर्थन के लिए विज्ञापन देखें",
        "settingsThanksForSupport": "Learn Anything का समर्थन करने के लिए धन्यवाद!",
        "supportFaqAdsAnswer": "कोई जबरन फुल-स्क्रीन विज्ञापन नहीं। क्विज़ परिणामों पर एक छोटा बैनर दिख सकता है। आप सेटिंग्स या सहायता से वैकल्पिक रूप से विज्ञापन देख सकते हैं।",
        "languageFontDownloadTitle": "फ़ॉन्ट डाउनलोड करें?",
        "languageFontDownloadBody": "इस भाषा के लिए अतिरिक्त फ़ॉन्ट चाहिए ताकि पाठ साफ़ दिखे (कुछ MB)। अभी डाउनलोड करें?",
        "languageFontDownloadAction": "डाउनलोड",
        "languageFontDownloadFailed": "फ़ॉन्ट डाउनलोड नहीं हो सके। कनेक्शन जाँचें और फिर कोशिश करें।",
        "languageFontDownloadSuccess": "इस भाषा के लिए फ़ॉन्ट तैयार हैं।",
        "languageFontDownloadProgress": "फ़ॉन्ट डाउनलोड हो रहे हैं...",
    },
    "te": {
        "supportAdReady": "వీడియో ప్రకటన సిద్ధం - చూడటానికి నొక్కండి",
        "supportAdUnavailable": "ప్రకటన లోడ్ అవుతోంది... కొద్దిసేపటి తర్వాత మళ్లీ ప్రయత్నించండి",
        "supportLoadingAd": "ప్రకటన లోడ్ అవుతోంది...",
        "settingsLoadingAd": "ప్రకటన లోడ్ అవుతోంది...",
        "supportWatchVideoTitle": "స్పాన్సర్డ్ వీడియో చూడండి",
        "settingsWatchAdToSupport": "మద్దతు కోసం ప్రకటన చూడండి",
        "settingsThanksForSupport": "Learn Anythingకు మద్దతు ఇచ్చినందుకు ధన్యవాదాలు!",
        "supportFaqAdsAnswer": "నిర్బంధ ఫుల్-స్క్రీన్ ప్రకటనలు లేవు. క్విజ్ ఫలితాలపై చిన్న బ్యానర్ కనిపించవచ్చు. సెట్టింగ్‌లు లేదా సపోర్ట్ నుండి మీరు ఐచ్ఛికంగా ప్రకటన చూడవచ్చు.",
        "languageFontDownloadTitle": "ఫాంట్‌లు డౌన్‌లోడ్ చేయాలా?",
        "languageFontDownloadBody": "ఈ భాషకు టెక్స్ట్ స్పష్టంగా కనిపించడానికి అదనపు ఫాంట్‌లు కావాలి (కొన్ని MB). ఇప్పుడు డౌన్‌లోడ్ చేయాలా?",
        "languageFontDownloadAction": "డౌన్‌లోడ్",
        "languageFontDownloadFailed": "ఫాంట్‌లు డౌన్‌లోడ్ కాలేదు. కనెక్షన్ తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.",
        "languageFontDownloadSuccess": "ఈ భాషకు ఫాంట్‌లు సిద్ధం.",
        "languageFontDownloadProgress": "ఫాంట్‌లు డౌన్‌లోడ్ అవుతున్నాయి...",
    },
    "ta": {
        "supportAdReady": "வீடியோ விளம்பரம் தயார் - பார்க்க தட்டவும்",
        "supportAdUnavailable": "விளம்பரம் ஏற்றுகிறது... சிறிது நேரம் கழித்து மீண்டும் முயலவும்",
        "supportLoadingAd": "விளம்பரம் ஏற்றுகிறது...",
        "settingsLoadingAd": "விளம்பரம் ஏற்றுகிறது...",
        "supportWatchVideoTitle": "ஸ்பான்சர் வீடியோவைப் பார்",
        "settingsWatchAdToSupport": "ஆதரிக்க விளம்பரம் பார்",
        "settingsThanksForSupport": "Learn Anything-ஐ ஆதரித்ததற்கு நன்றி!",
        "supportFaqAdsAnswer": "கட்டாய முழுத்திரை விளம்பரங்கள் இல்லை. வினாடி வினா முடிவுகளில் சிறிய பேனர் தோன்றலாம். அமைப்புகள் அல்லது ஆதரவிலிருந்து விருப்பமாக விளம்பரம் பார்க்கலாம்.",
        "languageFontDownloadTitle": "எழுத்துருக்களைப் பதிவிறக்கவா?",
        "languageFontDownloadBody": "உரை தெளிவாகத் தோன்ற இந்த மொழிக்கு கூடுதல் எழுத்துருக்கள் தேவை (சில MB). இப்போது பதிவிறக்கவா?",
        "languageFontDownloadAction": "பதிவிறக்கு",
        "languageFontDownloadFailed": "எழுத்துருக்களைப் பதிவிறக்க முடியவில்லை. இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.",
        "languageFontDownloadSuccess": "இந்த மொழிக்கான எழுத்துருக்கள் தயார்.",
        "languageFontDownloadProgress": "எழுத்துருக்கள் பதிவிறங்குகின்றன...",
    },
    "es": {
        "supportAdReady": "Anuncio de video listo - toca para ver",
        "supportAdUnavailable": "Cargando anuncio... vuelve a intentarlo en breve",
        "supportLoadingAd": "Cargando anuncio...",
        "settingsLoadingAd": "Cargando anuncio...",
        "supportWatchVideoTitle": "Ver video patrocinado",
        "settingsWatchAdToSupport": "Ver anuncio para apoyar",
        "settingsThanksForSupport": "Gracias por apoyar Learn Anything!",
        "supportFaqAdsAnswer": "No hay anuncios a pantalla completa obligatorios. Puede aparecer un banner pequeno en los resultados del quiz. Puedes ver un anuncio opcional desde Ajustes o Soporte.",
        "languageFontDownloadTitle": "Descargar fuentes?",
        "languageFontDownloadBody": "Este idioma necesita fuentes extra para mostrar el texto con claridad (unos MB). Descargar ahora?",
        "languageFontDownloadAction": "Descargar",
        "languageFontDownloadFailed": "No se pudieron descargar las fuentes. Revisa la conexion e intentalo de nuevo.",
        "languageFontDownloadSuccess": "Fuentes listas para este idioma.",
        "languageFontDownloadProgress": "Descargando fuentes...",
    },
    "fr": {
        "supportAdReady": "Pub video prete - appuyez pour regarder",
        "supportAdUnavailable": "Chargement de la pub... reessayez sous peu",
        "supportLoadingAd": "Chargement de la pub...",
        "settingsLoadingAd": "Chargement de la pub...",
        "supportWatchVideoTitle": "Regarder une video sponsorisee",
        "settingsWatchAdToSupport": "Regarder une pub pour soutenir",
        "settingsThanksForSupport": "Merci de soutenir Learn Anything!",
        "supportFaqAdsAnswer": "Pas de pubs plein ecran forcees. Une petite banniere peut apparaitre sur les resultats de quiz. Vous pouvez regarder une pub optionnelle depuis Reglages ou Support.",
        "languageFontDownloadTitle": "Telecharger les polices?",
        "languageFontDownloadBody": "Cette langue a besoin de polices supplementaires pour un affichage clair (quelques Mo). Telecharger maintenant?",
        "languageFontDownloadAction": "Telecharger",
        "languageFontDownloadFailed": "Impossible de telecharger les polices. Verifiez la connexion et reessayez.",
        "languageFontDownloadSuccess": "Polices pretes pour cette langue.",
        "languageFontDownloadProgress": "Telechargement des polices...",
    },
    "de": {
        "supportAdReady": "Videoanzeige bereit - tippen zum Ansehen",
        "supportAdUnavailable": "Anzeige wird geladen... bitte gleich erneut versuchen",
        "supportLoadingAd": "Anzeige wird geladen...",
        "settingsLoadingAd": "Anzeige wird geladen...",
        "supportWatchVideoTitle": "Gesponsertes Video ansehen",
        "settingsWatchAdToSupport": "Anzeige ansehen zur Unterstuetzung",
        "settingsThanksForSupport": "Danke, dass du Learn Anything unterstuetzt!",
        "supportFaqAdsAnswer": "Keine erzwungenen Vollbildanzeigen. Auf Quiz-Ergebnissen kann ein kleines Banner erscheinen. Optional kannst du eine Anzeige unter Einstellungen oder Support ansehen.",
        "languageFontDownloadTitle": "Schriftarten herunterladen?",
        "languageFontDownloadBody": "Diese Sprache benoetigt zusaetzliche Schriftarten fuer klare Darstellung (einige MB). Jetzt herunterladen?",
        "languageFontDownloadAction": "Herunterladen",
        "languageFontDownloadFailed": "Schriftarten konnten nicht geladen werden. Verbindung pruefen und erneut versuchen.",
        "languageFontDownloadSuccess": "Schriftarten fuer diese Sprache bereit.",
        "languageFontDownloadProgress": "Schriftarten werden geladen...",
    },
    "pt": {
        "supportAdReady": "Anuncio de video pronto - toque para assistir",
        "supportAdUnavailable": "Carregando anuncio... tente de novo em breve",
        "supportLoadingAd": "Carregando anuncio...",
        "settingsLoadingAd": "Carregando anuncio...",
        "supportWatchVideoTitle": "Assistir video patrocinado",
        "settingsWatchAdToSupport": "Assistir anuncio para apoiar",
        "settingsThanksForSupport": "Obrigado por apoiar o Learn Anything!",
        "supportFaqAdsAnswer": "Sem anuncios forcados em tela cheia. Um banner pequeno pode aparecer nos resultados do quiz. Voce pode assistir um anuncio opcional em Configuracoes ou Suporte.",
        "languageFontDownloadTitle": "Baixar fontes?",
        "languageFontDownloadBody": "Este idioma precisa de fontes extras para o texto ficar claro (alguns MB). Baixar agora?",
        "languageFontDownloadAction": "Baixar",
        "languageFontDownloadFailed": "Nao foi possivel baixar as fontes. Verifique a conexao e tente de novo.",
        "languageFontDownloadSuccess": "Fontes prontas para este idioma.",
        "languageFontDownloadProgress": "Baixando fontes...",
    },
    "zh": {
        "supportAdReady": "视频广告已就绪 - 点按观看",
        "supportAdUnavailable": "广告加载中... 请稍后重试",
        "supportLoadingAd": "正在加载广告...",
        "settingsLoadingAd": "正在加载广告...",
        "supportWatchVideoTitle": "观看赞助视频",
        "settingsWatchAdToSupport": "观看广告以支持我们",
        "settingsThanksForSupport": "感谢支持 Learn Anything！",
        "supportFaqAdsAnswer": "没有强制全屏广告。测验结果页可能显示小横幅。你可以在设置或支持中选择观看广告。",
        "languageFontDownloadTitle": "下载字体？",
        "languageFontDownloadBody": "此语言需要额外字体才能清晰显示文字（约几 MB）。立即下载？",
        "languageFontDownloadAction": "下载",
        "languageFontDownloadFailed": "无法下载字体。请检查网络后重试。",
        "languageFontDownloadSuccess": "此语言的字体已就绪。",
        "languageFontDownloadProgress": "正在下载字体...",
    },
    "ja": {
        "supportAdReady": "動画広告の準備完了 - タップして視聴",
        "supportAdUnavailable": "広告を読み込み中... しばらくしてから再試行してください",
        "supportLoadingAd": "広告を読み込み中...",
        "settingsLoadingAd": "広告を読み込み中...",
        "supportWatchVideoTitle": "スポンサー動画を見る",
        "settingsWatchAdToSupport": "広告を見て応援する",
        "settingsThanksForSupport": "Learn Anything を応援してくれてありがとう！",
        "supportFaqAdsAnswer": "強制フルスクリーン広告はありません。クイズ結果に小さなバナーが出ることがあります。設定またはサポートから任意で広告を視聴できます。",
        "languageFontDownloadTitle": "フォントをダウンロードしますか？",
        "languageFontDownloadBody": "この言語では文字をはっきり表示するために追加フォントが必要です（数 MB）。今ダウンロードしますか？",
        "languageFontDownloadAction": "ダウンロード",
        "languageFontDownloadFailed": "フォントをダウンロードできませんでした。接続を確認して再試行してください。",
        "languageFontDownloadSuccess": "この言語のフォントの準備ができました。",
        "languageFontDownloadProgress": "フォントをダウンロード中...",
    },
    # Blocked picker locales still keep ARBs in sync.
    "bn": {
        "supportAdReady": "ভিডিও বিজ্ঞাপন প্রস্তুত - দেখতে ট্যাপ করুন",
        "supportAdUnavailable": "বিজ্ঞাপন লোড হচ্ছে... একটু পরে আবার চেষ্টা করুন",
        "supportLoadingAd": "বিজ্ঞাপন লোড হচ্ছে...",
        "settingsLoadingAd": "বিজ্ঞাপন লোড হচ্ছে...",
        "supportWatchVideoTitle": "স্পন্সরড ভিডিও দেখুন",
        "settingsWatchAdToSupport": "সহায়তার জন্য বিজ্ঞাপন দেখুন",
        "settingsThanksForSupport": "Learn Anything সমর্থন করার জন্য ধন্যবাদ!",
        "supportFaqAdsAnswer": "জোর করে ফুল-স্ক্রিন বিজ্ঞাপন নেই। কুইজ ফলাফলে ছোট ব্যানার দেখা যেতে পারে। সেটিংস বা সাপোর্ট থেকে ইচ্ছামতো বিজ্ঞাপন দেখতে পারেন।",
        "languageFontDownloadTitle": "ফন্ট ডাউনলোড করবেন?",
        "languageFontDownloadBody": "টেক্সট স্পষ্ট দেখাতে এই ভাষায় অতিরিক্ত ফন্ট লাগে (কয়েক MB)। এখন ডাউনলোড করবেন?",
        "languageFontDownloadAction": "ডাউনলোড",
        "languageFontDownloadFailed": "ফন্ট ডাউনলোড হয়নি। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।",
        "languageFontDownloadSuccess": "এই ভাষার জন্য ফন্ট প্রস্তুত।",
        "languageFontDownloadProgress": "ফন্ট ডাউনলোড হচ্ছে...",
    },
    "ml": {
        "supportAdReady": "വീഡിയോ പരസ്യം തയ്യാർ - കാണാൻ ടാപ്പ് ചെയ്യുക",
        "supportAdUnavailable": "പരസ്യം ലോഡ് ചെയ്യുന്നു... അൽപ്പസമയം കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക",
        "supportLoadingAd": "പരസ്യം ലോഡ് ചെയ്യുന്നു...",
        "settingsLoadingAd": "പരസ്യം ലോഡ് ചെയ്യുന്നു...",
        "supportWatchVideoTitle": "സ്പോൺസർ വീഡിയോ കാണുക",
        "settingsWatchAdToSupport": "പിന്തുണയ്ക്ക് പരസ്യം കാണുക",
        "settingsThanksForSupport": "Learn Anything പിന്തുണച്ചതിന് നന്ദി!",
        "supportFaqAdsAnswer": "നിർബന്ധിത ഫുൾ-സ്ക്രീൻ പരസ്യങ്ങളില്ല. ക്വിസ് ഫലങ്ങളിൽ ചെറിയ ബാനർ കാണാം. സെറ്റിംഗ്സ് അല്ലെങ്കിൽ സപ്പോർട്ടിൽ നിന്ന് ഐച്ഛികമായി പരസ്യം കാണാം.",
        "languageFontDownloadTitle": "ഫോണ്ടുകൾ ഡൗൺലോഡ് ചെയ്യണോ?",
        "languageFontDownloadBody": "ടെക്സ്റ്റ് വ്യക്തമായി കാണാൻ ഈ ഭാഷയ്ക്ക് അധിക ഫോണ്ടുകൾ വേണം (കുറച്ച് MB). ഇപ്പോൾ ഡൗൺലോഡ് ചെയ്യണോ?",
        "languageFontDownloadAction": "ഡൗൺലോഡ്",
        "languageFontDownloadFailed": "ഫോണ്ടുകൾ ഡൗൺലോഡ് ചെയ്യാനായില്ല. കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.",
        "languageFontDownloadSuccess": "ഈ ഭാഷയ്ക്കുള്ള ഫോണ്ടുകൾ തയ്യാർ.",
        "languageFontDownloadProgress": "ഫോണ്ടുകൾ ഡൗൺലോഡ് ചെയ്യുന്നു...",
    },
    "mr": {
        "supportAdReady": "व्हिडिओ जाहिरात तयार आहे - पाहण्यासाठी टॅप करा",
        "supportAdUnavailable": "जाहिरात लोड होत आहे... थोड्या वेळाने पुन्हा प्रयत्न करा",
        "supportLoadingAd": "जाहिरात लोड होत आहे...",
        "settingsLoadingAd": "जाहिरात लोड होत आहे...",
        "supportWatchVideoTitle": "प्रायोजित व्हिडिओ पहा",
        "settingsWatchAdToSupport": "समर्थनासाठी जाहिरात पहा",
        "settingsThanksForSupport": "Learn Anything ला समर्थन दिल्याबद्दल धन्यवाद!",
        "supportFaqAdsAnswer": "सक्तीचे फुल-स्क्रीन जाहिराती नाहीत. क्विझ निकालांवर छोटा बॅनर दिसू शकतो. सेटिंग्ज किंवा सपोर्टमधून ऐच्छिक जाहिरात पाहता येते.",
        "languageFontDownloadTitle": "फॉन्ट डाउनलोड करायचे?",
        "languageFontDownloadBody": "मजकूर स्पष्ट दिसण्यासाठी या भाषेला अतिरिक्त फॉन्ट लागतात (काही MB). आता डाउनलोड करायचे?",
        "languageFontDownloadAction": "डाउनलोड",
        "languageFontDownloadFailed": "फॉन्ट डाउनलोड झाले नाहीत. कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.",
        "languageFontDownloadSuccess": "या भाषेसाठी फॉन्ट तयार आहेत.",
        "languageFontDownloadProgress": "फॉन्ट डाउनलोड होत आहेत...",
    },
}


def patch_arb(path: Path, updates: dict[str, str]) -> None:
    raw = path.read_text(encoding="utf-8-sig")
    data = json.loads(raw)
    for key, value in updates.items():
        data[key] = value
    # Keep @@locale first-ish: dump with ensure_ascii False
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )


def main() -> None:
    for loc, updates in TRANSLATIONS.items():
        path = L10N / f"app_{loc}.arb"
        if not path.exists():
            print(f"skip missing {path.name}")
            continue
        patch_arb(path, updates)
        print(f"patched {path.name} ({len(updates)} keys)")


if __name__ == "__main__":
    main()
