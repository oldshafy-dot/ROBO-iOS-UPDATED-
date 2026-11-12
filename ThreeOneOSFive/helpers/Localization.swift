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
        if let value = additionalTranslations[rawValue]?[key] {
            return value
        }
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }

    func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: arguments)
    }

    func licenseMessage(_ message: String) -> String {
        switch message {
        case "Invalid License":
            return text("license.invalid_key")
        case "Finishing activation. Keep the app open.":
            return text("license.finishing_activation")
        case "Activation did not complete. Enter your license key to try again.":
            return text("license.activation_incomplete")
        case "Could not confirm activation. Enter your license key to try again.":
            return text("license.activation_unconfirmed")
        default:
            return message
        }
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

    private var additionalTranslations: [String: [String: String]] {
        [
            "en": [
                "dashboard.hardware_model": "Hardware model", "settings.ios_version": "iOS Version",
                "settings.current_version": "Current version", "status.not_attempted": "Not attempted",
                "status.ok_via": "OK via %@", "status.failed_via": "FAILED %@ (%lld)",
                "status.unsupported_reason": "Unsupported: %@", "method.simulator_preview": "Simulator preview",
                "tab.account": "Account", "common.settings": "Settings", "common.ok": "OK", "common.close": "Close",
                "content.checking_updates": "Checking for updates…",
                "content.no_functions": "No functions yet. They will appear after an update.",
                "license.loading": "Loading…", "license.loading_accessibility": "Loading",
                "license.retry": "Retry", "license.log_out": "Log out",
                "license.key_title": "LICENSE KEY", "license.key_placeholder": "Enter license key",
                "license.key_accessibility": "License key", "license.activate": "Activate",
                "license.activating": "Activating…", "license.robo_official_accessibility": "ROBO OFFICIAL on Telegram",
                "license.shafay_dev_accessibility": "Shafay Dev on Telegram", "license.open_bot_title": "Open Bot",
                "license.daily_updates": "for Daily Updates", "license.open_bot": "Open Bot",
                "license.about_title": "About Robo iOS",
                "license.about_description": "It's an iOS app that controls functions and tools, designed by Shafay.",
                "license.streamer_mode": "Streamer Mode", "license.configuration_title": "Licensing not configured",
                "license.configuration_detail": "Access remains locked until a valid HTTPS server and Ed25519 key are configured.",
                "license.unavailable_title": "License unavailable",
                "license.unavailable_detail": "The app is locked because the session could not be securely validated.",
                "license.whats_new": "What's New",
                "license.update_default_description": "Update required before functions can be used.",
                "license.installing": "Installing…", "license.download_install": "Download & Install",
                "license.required": "License required.",
                "license.device_preparation_failed": "Device preparation failed. Restart the app and try again.",
                "license.activation_error_accessibility": "Activation error. %@",
                "license.update_error_accessibility": "Update error. %@",
                "license.open_bot_accessibility": "Open Bot",
                "license.update_accessibility_hint": "Downloads and verifies the required data packages.",
                "license.invalid_key": "Invalid License",
                "license.finishing_activation": "Finishing activation. Keep the app open.",
                "license.activation_incomplete": "Activation did not complete. Enter your license key to try again.",
                "license.activation_unconfirmed": "Could not confirm activation. Enter your license key to try again.",
                "game.normal": "Normal", "game.max": "MAX", "game.ready": "Ready",
                "settings.color_gold": "Gold", "settings.color_green": "Green"
            ],
            "pt": [
                "dashboard.hardware_model": "Modelo de hardware", "settings.ios_version": "Versão do iOS",
                "settings.current_version": "Versão atual", "status.not_attempted": "Não iniciado",
                "status.ok_via": "OK via %@", "status.failed_via": "FALHOU %@ (%lld)",
                "status.unsupported_reason": "Incompatível: %@", "method.simulator_preview": "Prévia do simulador",
                "tab.account": "Conta", "common.settings": "Configurações", "common.ok": "OK", "common.close": "Fechar",
                "content.checking_updates": "Verificando atualizações…",
                "content.no_functions": "Ainda não há funções. Elas aparecerão após uma atualização.",
                "license.loading": "Carregando…", "license.loading_accessibility": "Carregando",
                "license.retry": "Tentar novamente", "license.log_out": "Sair",
                "license.key_title": "CHAVE DE LICENÇA", "license.key_placeholder": "Digite a chave de licença",
                "license.key_accessibility": "Chave de licença", "license.activate": "Ativar",
                "license.activating": "Ativando…", "license.robo_official_accessibility": "ROBO OFFICIAL no Telegram",
                "license.shafay_dev_accessibility": "Shafay Dev no Telegram", "license.open_bot_title": "Abrir bot",
                "license.daily_updates": "para atualizações diárias", "license.open_bot": "Abrir bot",
                "license.about_title": "Sobre o Robo iOS",
                "license.about_description": "É um aplicativo iOS para controlar funções e ferramentas, desenvolvido por Shafay.",
                "license.streamer_mode": "Modo Streamer", "license.configuration_title": "Licenciamento não configurado",
                "license.configuration_detail": "O acesso permanecerá bloqueado até que um servidor HTTPS válido e uma chave Ed25519 sejam configurados.",
                "license.unavailable_title": "Licença indisponível",
                "license.unavailable_detail": "O aplicativo está bloqueado porque a sessão não pôde ser validada com segurança.",
                "license.whats_new": "Novidades",
                "license.update_default_description": "É necessária uma atualização antes de usar as funções.",
                "license.installing": "Instalando…", "license.download_install": "Baixar e instalar",
                "license.required": "É necessária uma licença.",
                "license.device_preparation_failed": "Falha na preparação do dispositivo. Reinicie o app e tente novamente.",
                "license.activation_error_accessibility": "Erro de ativação. %@",
                "license.update_error_accessibility": "Erro de atualização. %@",
                "license.open_bot_accessibility": "Abrir bot",
                "license.update_accessibility_hint": "Baixa e verifica os pacotes de dados necessários.",
                "license.invalid_key": "Licença inválida",
                "license.finishing_activation": "Finalizando a ativação. Mantenha o app aberto.",
                "license.activation_incomplete": "A ativação não foi concluída. Digite sua chave de licença novamente.",
                "license.activation_unconfirmed": "Não foi possível confirmar a ativação. Digite sua chave de licença novamente.",
                "game.normal": "Normal", "game.max": "MAX", "game.ready": "Pronto",
                "settings.color_gold": "Dourado", "settings.color_green": "Verde"
            ],
            "ar": [
                "dashboard.hardware_model": "طراز الجهاز", "settings.ios_version": "إصدار iOS",
                "settings.current_version": "الإصدار الحالي", "status.not_attempted": "لم تتم المحاولة",
                "status.ok_via": "تم عبر %@", "status.failed_via": "فشل %@ (%lld)",
                "status.unsupported_reason": "غير مدعوم: %@", "method.simulator_preview": "معاينة المحاكي",
                "tab.account": "الحساب", "common.settings": "الإعدادات", "common.ok": "حسنًا", "common.close": "إغلاق",
                "content.checking_updates": "جارٍ التحقق من التحديثات…",
                "content.no_functions": "لا توجد وظائف بعد. ستظهر بعد التحديث.",
                "license.loading": "جارٍ التحميل…", "license.loading_accessibility": "تحميل",
                "license.retry": "إعادة المحاولة", "license.log_out": "تسجيل الخروج",
                "license.key_title": "مفتاح الترخيص", "license.key_placeholder": "أدخل مفتاح الترخيص",
                "license.key_accessibility": "مفتاح الترخيص", "license.activate": "تفعيل",
                "license.activating": "جارٍ التفعيل…", "license.robo_official_accessibility": "ROBO OFFICIAL على تيليجرام",
                "license.shafay_dev_accessibility": "Shafay Dev على تيليجرام", "license.open_bot_title": "افتح البوت",
                "license.daily_updates": "للتحديثات اليومية", "license.open_bot": "افتح البوت",
                "license.about_title": "حول Robo iOS",
                "license.about_description": "تطبيق iOS للتحكم في الوظائف والأدوات، من تصميم Shafay.",
                "license.streamer_mode": "وضع البث", "license.configuration_title": "الترخيص غير مُعد",
                "license.configuration_detail": "سيظل الوصول مقفلًا حتى يتم إعداد خادم HTTPS صالح ومفتاح Ed25519.",
                "license.unavailable_title": "الترخيص غير متاح",
                "license.unavailable_detail": "التطبيق مقفل لأنه تعذّر التحقق من الجلسة بأمان.",
                "license.whats_new": "ما الجديد",
                "license.update_default_description": "يلزم التحديث قبل استخدام الوظائف.",
                "license.installing": "جارٍ التثبيت…", "license.download_install": "تنزيل وتثبيت",
                "license.required": "يلزم الترخيص.",
                "license.device_preparation_failed": "تعذّر تجهيز الجهاز. أعد تشغيل التطبيق وحاول مجددًا.",
                "license.activation_error_accessibility": "خطأ في التفعيل. %@",
                "license.update_error_accessibility": "خطأ في التحديث. %@",
                "license.open_bot_accessibility": "افتح البوت",
                "license.update_accessibility_hint": "ينزّل حزم البيانات المطلوبة ويتحقق منها.",
                "license.invalid_key": "مفتاح الترخيص غير صالح",
                "license.finishing_activation": "جارٍ إنهاء التفعيل. أبقِ التطبيق مفتوحًا.",
                "license.activation_incomplete": "لم يكتمل التفعيل. أدخل مفتاح الترخيص مرة أخرى.",
                "license.activation_unconfirmed": "تعذّر تأكيد التفعيل. أدخل مفتاح الترخيص مرة أخرى.",
                "game.normal": "عادي", "game.max": "MAX", "game.ready": "جاهز",
                "settings.color_gold": "ذهبي", "settings.color_green": "أخضر"
            ],
            "bn": [
                "dashboard.hardware_model": "হার্ডওয়্যার মডেল", "settings.ios_version": "iOS সংস্করণ",
                "settings.current_version": "বর্তমান সংস্করণ", "status.not_attempted": "চেষ্টা করা হয়নি",
                "status.ok_via": "%@ দিয়ে সফল", "status.failed_via": "ব্যর্থ %@ (%lld)",
                "status.unsupported_reason": "অসমর্থিত: %@", "method.simulator_preview": "সিমুলেটর প্রিভিউ",
                "tab.account": "অ্যাকাউন্ট", "common.settings": "সেটিংস", "common.ok": "ঠিক আছে", "common.close": "বন্ধ",
                "content.checking_updates": "আপডেট পরীক্ষা করা হচ্ছে…",
                "content.no_functions": "এখনও কোনো ফাংশন নেই। আপডেটের পরে দেখা যাবে।",
                "license.loading": "লোড হচ্ছে…", "license.loading_accessibility": "লোড হচ্ছে",
                "license.retry": "আবার চেষ্টা করুন", "license.log_out": "লগ আউট",
                "license.key_title": "লাইসেন্স কী", "license.key_placeholder": "লাইসেন্স কী লিখুন",
                "license.key_accessibility": "লাইসেন্স কী", "license.activate": "সক্রিয় করুন",
                "license.activating": "সক্রিয় করা হচ্ছে…", "license.robo_official_accessibility": "Telegram-এ ROBO OFFICIAL",
                "license.shafay_dev_accessibility": "Telegram-এ Shafay Dev", "license.open_bot_title": "বট খুলুন",
                "license.daily_updates": "দৈনিক আপডেটের জন্য", "license.open_bot": "বট খুলুন",
                "license.about_title": "Robo iOS সম্পর্কে",
                "license.about_description": "Shafay-এর তৈরি ফাংশন ও টুল নিয়ন্ত্রণের একটি iOS অ্যাপ।",
                "license.streamer_mode": "স্ট্রিমার মোড", "license.configuration_title": "লাইসেন্স কনফিগার করা হয়নি",
                "license.configuration_detail": "সঠিক HTTPS সার্ভার এবং Ed25519 কী সেট না করা পর্যন্ত অ্যাক্সেস বন্ধ থাকবে।",
                "license.unavailable_title": "লাইসেন্স উপলভ্য নয়",
                "license.unavailable_detail": "সেশন নিরাপদে যাচাই করা যায়নি বলে অ্যাপটি লক করা আছে।",
                "license.whats_new": "নতুন কী",
                "license.update_default_description": "ফাংশন ব্যবহার করার আগে আপডেট প্রয়োজন।",
                "license.installing": "ইনস্টল হচ্ছে…", "license.download_install": "ডাউনলোড ও ইনস্টল",
                "license.required": "লাইসেন্স প্রয়োজন।",
                "license.device_preparation_failed": "ডিভাইস প্রস্তুত করা যায়নি। অ্যাপ পুনরায় চালু করে চেষ্টা করুন।",
                "license.activation_error_accessibility": "সক্রিয়করণে ত্রুটি। %@",
                "license.update_error_accessibility": "আপডেটে ত্রুটি। %@",
                "license.open_bot_accessibility": "বট খুলুন",
                "license.update_accessibility_hint": "প্রয়োজনীয় ডেটা প্যাকেজ ডাউনলোড ও যাচাই করে।",
                "license.invalid_key": "ভুল লাইসেন্স",
                "license.finishing_activation": "সক্রিয়করণ শেষ হচ্ছে। অ্যাপ খোলা রাখুন।",
                "license.activation_incomplete": "সক্রিয়করণ সম্পন্ন হয়নি। আবার লাইসেন্স কী লিখুন।",
                "license.activation_unconfirmed": "সক্রিয়করণ নিশ্চিত করা যায়নি। আবার লাইসেন্স কী লিখুন।",
                "game.normal": "সাধারণ", "game.max": "MAX", "game.ready": "প্রস্তুত",
                "settings.color_gold": "সোনালি", "settings.color_green": "সবুজ"
            ],
            "es": [
                "dashboard.hardware_model": "Modelo de hardware", "settings.ios_version": "Versión de iOS",
                "settings.current_version": "Versión actual", "status.not_attempted": "No intentado",
                "status.ok_via": "Correcto mediante %@", "status.failed_via": "FALLÓ %@ (%lld)",
                "status.unsupported_reason": "No compatible: %@", "method.simulator_preview": "Vista previa del simulador",
                "tab.account": "Cuenta", "common.settings": "Ajustes", "common.ok": "Aceptar", "common.close": "Cerrar",
                "content.checking_updates": "Buscando actualizaciones…",
                "content.no_functions": "Todavía no hay funciones. Aparecerán después de una actualización.",
                "license.loading": "Cargando…", "license.loading_accessibility": "Cargando",
                "license.retry": "Reintentar", "license.log_out": "Cerrar sesión",
                "license.key_title": "CLAVE DE LICENCIA", "license.key_placeholder": "Introduce la clave de licencia",
                "license.key_accessibility": "Clave de licencia", "license.activate": "Activar",
                "license.activating": "Activando…", "license.robo_official_accessibility": "ROBO OFFICIAL en Telegram",
                "license.shafay_dev_accessibility": "Shafay Dev en Telegram", "license.open_bot_title": "Abrir bot",
                "license.daily_updates": "para actualizaciones diarias", "license.open_bot": "Abrir bot",
                "license.about_title": "Acerca de Robo iOS",
                "license.about_description": "Es una app de iOS para controlar funciones y herramientas, diseñada por Shafay.",
                "license.streamer_mode": "Modo streamer", "license.configuration_title": "Licencia no configurada",
                "license.configuration_detail": "El acceso seguirá bloqueado hasta configurar un servidor HTTPS válido y una clave Ed25519.",
                "license.unavailable_title": "Licencia no disponible",
                "license.unavailable_detail": "La app está bloqueada porque no se pudo validar la sesión de forma segura.",
                "license.whats_new": "Novedades",
                "license.update_default_description": "Se requiere una actualización antes de usar las funciones.",
                "license.installing": "Instalando…", "license.download_install": "Descargar e instalar",
                "license.required": "Se requiere una licencia.",
                "license.device_preparation_failed": "No se pudo preparar el dispositivo. Reinicia la app e inténtalo de nuevo.",
                "license.activation_error_accessibility": "Error de activación. %@",
                "license.update_error_accessibility": "Error de actualización. %@",
                "license.open_bot_accessibility": "Abrir bot",
                "license.update_accessibility_hint": "Descarga y verifica los paquetes de datos necesarios.",
                "license.invalid_key": "Licencia no válida",
                "license.finishing_activation": "Finalizando la activación. Mantén la app abierta.",
                "license.activation_incomplete": "La activación no se completó. Introduce de nuevo tu clave de licencia.",
                "license.activation_unconfirmed": "No se pudo confirmar la activación. Introduce de nuevo tu clave de licencia.",
                "game.normal": "Normal", "game.max": "MAX", "game.ready": "Listo",
                "settings.color_gold": "Dorado", "settings.color_green": "Verde"
            ],
            "tr": [
                "dashboard.hardware_model": "Donanım modeli", "settings.ios_version": "iOS Sürümü",
                "settings.current_version": "Mevcut sürüm", "status.not_attempted": "Denenmedi",
                "status.ok_via": "%@ ile başarılı", "status.failed_via": "BAŞARISIZ %@ (%lld)",
                "status.unsupported_reason": "Desteklenmiyor: %@", "method.simulator_preview": "Simülatör önizlemesi",
                "tab.account": "Hesap", "common.settings": "Ayarlar", "common.ok": "Tamam", "common.close": "Kapat",
                "content.checking_updates": "Güncellemeler denetleniyor…",
                "content.no_functions": "Henüz işlev yok. Güncellemeden sonra görünecekler.",
                "license.loading": "Yükleniyor…", "license.loading_accessibility": "Yükleniyor",
                "license.retry": "Yeniden dene", "license.log_out": "Çıkış yap",
                "license.key_title": "LİSANS ANAHTARI", "license.key_placeholder": "Lisans anahtarını girin",
                "license.key_accessibility": "Lisans anahtarı", "license.activate": "Etkinleştir",
                "license.activating": "Etkinleştiriliyor…", "license.robo_official_accessibility": "Telegram'da ROBO OFFICIAL",
                "license.shafay_dev_accessibility": "Telegram'da Shafay Dev", "license.open_bot_title": "Botu aç",
                "license.daily_updates": "günlük güncellemeler için", "license.open_bot": "Botu aç",
                "license.about_title": "Robo iOS Hakkında",
                "license.about_description": "Shafay tarafından tasarlanan, işlevleri ve araçları kontrol eden bir iOS uygulamasıdır.",
                "license.streamer_mode": "Yayıncı Modu", "license.configuration_title": "Lisans yapılandırılmadı",
                "license.configuration_detail": "Geçerli bir HTTPS sunucusu ve Ed25519 anahtarı ayarlanana kadar erişim kilitli kalır.",
                "license.unavailable_title": "Lisans kullanılamıyor",
                "license.unavailable_detail": "Oturum güvenli şekilde doğrulanamadığı için uygulama kilitlendi.",
                "license.whats_new": "Yenilikler",
                "license.update_default_description": "İşlevleri kullanmadan önce güncelleme gerekir.",
                "license.installing": "Yükleniyor…", "license.download_install": "İndir ve yükle",
                "license.required": "Lisans gerekiyor.",
                "license.device_preparation_failed": "Cihaz hazırlanamadı. Uygulamayı yeniden başlatıp tekrar deneyin.",
                "license.activation_error_accessibility": "Etkinleştirme hatası. %@",
                "license.update_error_accessibility": "Güncelleme hatası. %@",
                "license.open_bot_accessibility": "Botu aç",
                "license.update_accessibility_hint": "Gerekli veri paketlerini indirir ve doğrular.",
                "license.invalid_key": "Geçersiz lisans",
                "license.finishing_activation": "Etkinleştirme tamamlanıyor. Uygulamayı açık tutun.",
                "license.activation_incomplete": "Etkinleştirme tamamlanmadı. Lisans anahtarınızı yeniden girin.",
                "license.activation_unconfirmed": "Etkinleştirme doğrulanamadı. Lisans anahtarınızı yeniden girin.",
                "game.normal": "Normal", "game.max": "MAX", "game.ready": "Hazır",
                "settings.color_gold": "Altın", "settings.color_green": "Yeşil"
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
