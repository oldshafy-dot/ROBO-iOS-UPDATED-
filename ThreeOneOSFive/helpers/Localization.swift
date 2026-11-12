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
            "en": [
                "settings.appearance": "Appearance",
                "settings.dark_mode": "Dark Mode",
                "settings.light_mode": "Light Mode",
                "settings.streamer_on": "ON",
                "settings.streamer_off": "OFF",
                "common.select_app": "Select App",
                "common.functions": "Functions",
                "common.change": "Change",
                "common.device": "Device",
                "common.license": "License",
                "common.app": "App",
                "common.contact": "Contact",
                "common.sign_out": "Sign Out",
                "common.expiry": "Expiry",
                "common.name": "Name",
                "common.version": "Version",
                "common.model": "Model",
                "common.build": "Build",
                "common.supported": "Supported",
                "common.unsupported": "Unsupported",
                "common.ready_to_use": "Ready to use functions",
                "common.ios_not_supported": "This iOS version is not supported",
                "common.play_beyond_limits": "Play Beyond Limits",
                "common.expired": "Expired",
                "common.left": "left",
                "settings.title": "Robo iOS", "settings.subtitle": "Customize your app",
                "settings.language": "Language", "settings.accent_color": "Accent Color",
                "settings.custom_color": "Custom Color", "settings.apply": "Apply",
                "settings.no_black": "Black cannot be used as an accent color.",
                "settings.streamer_mode": "Streamer Mode", "settings.streamer_mode_footer": "During screen recording or streaming, normal app content is replaced by the About Robo iOS privacy screen.",
                "settings.save": "Save Settings", "settings.saved": "Settings Saved",
                "settings.invalid_color": "Invalid Color", "settings.invalid_color_message": "Enter a valid hex code such as #F53331. Black is not allowed.",
                "settings.color_blue": "Blue", "settings.color_red": "Red", "settings.color_purple": "Purple", "settings.color_orange": "Orange",
                "common.back": "Back", "common.done": "Done", "settings.supported": "Supported", "settings.unsupported": "Unsupported"
            ],
            "pt": [
                "settings.appearance": "Aparência",
                "settings.dark_mode": "Modo escuro",
                "settings.light_mode": "Modo claro",
                "settings.streamer_on": "ATIVADO",
                "settings.streamer_off": "DESATIVADO",
                "common.select_app": "Selecionar aplicativo",
                "common.functions": "Funções",
                "common.change": "Alterar",
                "common.device": "Dispositivo",
                "common.license": "Licença",
                "common.app": "Aplicativo",
                "common.contact": "Contato",
                "common.sign_out": "Sair",
                "common.expiry": "Expiração",
                "common.name": "Nome",
                "common.version": "Versão",
                "common.model": "Modelo",
                "common.build": "Build",
                "common.supported": "Compatível",
                "common.unsupported": "Incompatível",
                "common.ready_to_use": "Pronto para usar as funções",
                "common.ios_not_supported": "Esta versão do iOS não é compatível",
                "common.play_beyond_limits": "Jogue sem limites",
                "common.expired": "Expirado",
                "common.left": "restante",
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
                "settings.appearance": "المظهر",
                "settings.dark_mode": "الوضع الداكن",
                "settings.light_mode": "الوضع الفاتح",
                "settings.streamer_on": "مفعل",
                "settings.streamer_off": "متوقف",
                "common.select_app": "اختيار التطبيق",
                "common.functions": "الوظائف",
                "common.change": "تغيير",
                "common.device": "الجهاز",
                "common.license": "الترخيص",
                "common.app": "التطبيق",
                "common.contact": "جهة الاتصال",
                "common.sign_out": "تسجيل الخروج",
                "common.expiry": "الانتهاء",
                "common.name": "الاسم",
                "common.version": "الإصدار",
                "common.model": "الطراز",
                "common.build": "البنية",
                "common.supported": "مدعوم",
                "common.unsupported": "غير مدعوم",
                "common.ready_to_use": "جاهز لاستخدام الوظائف",
                "common.ios_not_supported": "إصدار iOS هذا غير مدعوم",
                "common.play_beyond_limits": "العب بلا حدود",
                "common.expired": "منتهي",
                "common.left": "متبقي",
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
                "settings.appearance": "চেহারা",
                "settings.dark_mode": "ডার্ক মোড",
                "settings.light_mode": "লাইট মোড",
                "settings.streamer_on": "চালু",
                "settings.streamer_off": "বন্ধ",
                "common.select_app": "অ্যাপ নির্বাচন করুন",
                "common.functions": "ফাংশন",
                "common.change": "পরিবর্তন",
                "common.device": "ডিভাইস",
                "common.license": "লাইসেন্স",
                "common.app": "অ্যাপ",
                "common.contact": "যোগাযোগ",
                "common.sign_out": "সাইন আউট",
                "common.expiry": "মেয়াদ",
                "common.name": "নাম",
                "common.version": "ভার্সন",
                "common.model": "মডেল",
                "common.build": "বিল্ড",
                "common.supported": "সমর্থিত",
                "common.unsupported": "অসমর্থিত",
                "common.ready_to_use": "ফাংশন ব্যবহারের জন্য প্রস্তুত",
                "common.ios_not_supported": "এই iOS সংস্করণ সমর্থিত নয়",
                "common.play_beyond_limits": "সীমার বাইরে খেলুন",
                "common.expired": "মেয়াদ শেষ",
                "common.left": "বাকি",
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
                "settings.appearance": "Apariencia",
                "settings.dark_mode": "Modo oscuro",
                "settings.light_mode": "Modo claro",
                "settings.streamer_on": "ACTIVADO",
                "settings.streamer_off": "DESACTIVADO",
                "common.select_app": "Seleccionar app",
                "common.functions": "Funciones",
                "common.change": "Cambiar",
                "common.device": "Dispositivo",
                "common.license": "Licencia",
                "common.app": "App",
                "common.contact": "Contacto",
                "common.sign_out": "Cerrar sesión",
                "common.expiry": "Caducidad",
                "common.name": "Nombre",
                "common.version": "Versión",
                "common.model": "Modelo",
                "common.build": "Compilación",
                "common.supported": "Compatible",
                "common.unsupported": "No compatible",
                "common.ready_to_use": "Listo para usar las funciones",
                "common.ios_not_supported": "Esta versión de iOS no es compatible",
                "common.play_beyond_limits": "Juega sin límites",
                "common.expired": "Caducado",
                "common.left": "restante",
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
                "settings.appearance": "Görünüm",
                "settings.dark_mode": "Karanlık Mod",
                "settings.light_mode": "Açık Mod",
                "settings.streamer_on": "AÇIK",
                "settings.streamer_off": "KAPALI",
                "common.select_app": "Uygulama seç",
                "common.functions": "İşlevler",
                "common.change": "Değiştir",
                "common.device": "Cihaz",
                "common.license": "Lisans",
                "common.app": "Uygulama",
                "common.contact": "İletişim",
                "common.sign_out": "Çıkış yap",
                "common.expiry": "Son kullanma",
                "common.name": "Ad",
                "common.version": "Sürüm",
                "common.model": "Model",
                "common.build": "Derleme",
                "common.supported": "Destekleniyor",
                "common.unsupported": "Desteklenmiyor",
                "common.ready_to_use": "İşlevleri kullanmaya hazır",
                "common.ios_not_supported": "Bu iOS sürümü desteklenmiyor",
                "common.play_beyond_limits": "Sınırların ötesinde oyna",
                "common.expired": "Süresi doldu",
                "common.left": "kaldı",
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
