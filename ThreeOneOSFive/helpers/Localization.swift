import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "appLanguage"

    case english = "en"
    case portuguese = "pt"
    case arabic = "ar"
    case bengali = "bn"
    case spanish = "es"
    case turkish = "tr"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .portuguese: return "Português"
        case .arabic: return "العربية"
        case .bengali: return "বাংলা"
        case .spanish: return "Español"
        case .turkish: return "Türkçe"
        }
    }

    func text(_ key: String) -> String {
        if let value = translations[rawValue]?[key] {
            return value
        }
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }

    func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: arguments)
    }

    private var translations: [String: [String: String]] {
        [
            "pt": [
                "settings.title": "Robo iOS", "settings.subtitle": "Personalize o aplicativo",
                "settings.language": "Idioma", "settings.accent_color": "Cor de destaque",
                "settings.custom_color": "Cor personalizada", "settings.apply": "Aplicar",
                "settings.no_black": "Preto não pode ser usado como cor de destaque.",
                "settings.streamer_mode": "Modo Streamer", "settings.streamer_mode_footer": "Durante gravação ou transmissão, o conteúdo normal é substituído pela tela Sobre o Robo iOS.",
                "settings.save": "Salvar configurações", "settings.saved": "Configurações salvas",
                "settings.invalid_color": "Cor inválida", "settings.invalid_color_message": "Use um código hexadecimal válido como #F53331 e não use preto.",
                "settings.color_blue": "Azul", "settings.color_red": "Vermelho", "settings.color_purple": "Roxo", "settings.color_orange": "Laranja",
                "common.back": "Voltar", "common.done": "Concluído", "settings.supported": "Compatível", "settings.unsupported": "Incompatível"
            ],
            "ar": [
                "settings.title": "Robo iOS", "settings.subtitle": "تخصيص التطبيق",
                "settings.language": "اللغة", "settings.accent_color": "لون الواجهة",
                "settings.custom_color": "لون مخصص", "settings.apply": "تطبيق",
                "settings.no_black": "لا يمكن استخدام الأسود كلون للواجهة.",
                "settings.streamer_mode": "وضع البث", "settings.streamer_mode_footer": "أثناء تسجيل الشاشة أو البث، يتم استبدال محتوى التطبيق بشاشة حول Robo iOS.",
                "settings.save": "حفظ الإعدادات", "settings.saved": "تم حفظ الإعدادات",
                "settings.invalid_color": "لون غير صالح", "settings.invalid_color_message": "استخدم رمزًا سداسيًا صالحًا مثل #F53331 ولا تستخدم الأسود.",
                "settings.color_blue": "أزرق", "settings.color_red": "أحمر", "settings.color_purple": "بنفسجي", "settings.color_orange": "برتقالي",
                "common.back": "رجوع", "common.done": "تم", "settings.supported": "مدعوم", "settings.unsupported": "غير مدعوم"
            ],
            "bn": [
                "settings.title": "Robo iOS", "settings.subtitle": "অ্যাপটি কাস্টমাইজ করুন",
                "settings.language": "ভাষা", "settings.accent_color": "অ্যাকসেন্ট রঙ",
                "settings.custom_color": "কাস্টম রঙ", "settings.apply": "প্রয়োগ",
                "settings.no_black": "কালো অ্যাকসেন্ট রঙ হিসেবে ব্যবহার করা যাবে না।",
                "settings.streamer_mode": "স্ট্রিমার মোড", "settings.streamer_mode_footer": "স্ক্রিন রেকর্ড বা স্ট্রিম করার সময় স্বাভাবিক কনটেন্টের বদলে Robo iOS সম্পর্কে স্ক্রিন দেখানো হবে।",
                "settings.save": "সেটিংস সংরক্ষণ করুন", "settings.saved": "সেটিংস সংরক্ষিত",
                "settings.invalid_color": "ভুল রঙ", "settings.invalid_color_message": "#F53331-এর মতো বৈধ হেক্স কোড ব্যবহার করুন এবং কালো ব্যবহার করবেন না।",
                "settings.color_blue": "নীল", "settings.color_red": "লাল", "settings.color_purple": "বেগুনি", "settings.color_orange": "কমলা",
                "common.back": "ফিরে যান", "common.done": "সম্পন্ন", "settings.supported": "সমর্থিত", "settings.unsupported": "অসমর্থিত"
            ],
            "es": [
                "settings.title": "Robo iOS", "settings.subtitle": "Personaliza la aplicación",
                "settings.language": "Idioma", "settings.accent_color": "Color de acento",
                "settings.custom_color": "Color personalizado", "settings.apply": "Aplicar",
                "settings.no_black": "El negro no se puede usar como color de acento.",
                "settings.streamer_mode": "Modo streamer", "settings.streamer_mode_footer": "Durante la grabación o transmisión, el contenido normal se reemplaza por la pantalla Acerca de Robo iOS.",
                "settings.save": "Guardar configuración", "settings.saved": "Configuración guardada",
                "settings.invalid_color": "Color no válido", "settings.invalid_color_message": "Usa un código hexadecimal válido como #F53331 y no uses negro.",
                "settings.color_blue": "Azul", "settings.color_red": "Rojo", "settings.color_purple": "Morado", "settings.color_orange": "Naranja",
                "common.back": "Atrás", "common.done": "Listo", "settings.supported": "Compatible", "settings.unsupported": "No compatible"
            ],
            "tr": [
                "settings.title": "Robo iOS", "settings.subtitle": "Uygulamayı özelleştir",
                "settings.language": "Dil", "settings.accent_color": "Vurgu rengi",
                "settings.custom_color": "Özel renk", "settings.apply": "Uygula",
                "settings.no_black": "Siyah vurgu rengi olarak kullanılamaz.",
                "settings.streamer_mode": "Yayıncı Modu", "settings.streamer_mode_footer": "Ekran kaydı veya yayın sırasında normal içerik yerine Robo iOS Hakkında ekranı gösterilir.",
                "settings.save": "Ayarları Kaydet", "settings.saved": "Ayarlar kaydedildi",
                "settings.invalid_color": "Geçersiz renk", "settings.invalid_color_message": "#F53331 gibi geçerli bir hex kodu kullanın ve siyah kullanmayın.",
                "settings.color_blue": "Mavi", "settings.color_red": "Kırmızı", "settings.color_purple": "Mor", "settings.color_orange": "Turuncu",
                "common.back": "Geri", "common.done": "Bitti", "settings.supported": "Destekleniyor", "settings.unsupported": "Desteklenmiyor"
            ]
        ]
    }
}

private struct AppLanguageEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppLanguage.english
}

extension EnvironmentValues {
    var appLanguage: AppLanguage {
        get { self[AppLanguageEnvironmentKey.self] }
        set { self[AppLanguageEnvironmentKey.self] = newValue }
    }
}

extension ExploitStatus {
    func displayText(language: AppLanguage) -> String {
        switch self {
        case .notStarted:
            return language.text("status.not_attempted")
        case .success(let method):
            let localizedMethod = method == "Simulator preview"
                ? language.text("method.simulator_preview")
                : method
            return language.text("status.ok_via", localizedMethod)
        case .failed(let method, let code):
            return language.text("status.failed_via", method, code)
        case .unsupported(let message):
            return language.text("status.unsupported_reason", message)
        }
    }
}
