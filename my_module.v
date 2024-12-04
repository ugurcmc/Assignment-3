
## Authorization System

module authorization_system(
    input [7:0] username,       // 8-bit kullanıcı adı
    input [7:0] password,       // 8-bit şifre
    output authorized           // Yetkilendirme sinyali
);

    // Sabit kullanıcı adı ve şifre tanımları
    parameter [7:0] USERNAME = 8'h55;  // Kullanıcı adı: 0x55
    parameter [7:0] PASSWORD = 8'hAA;  // Şifre: 0xAA

    // Yetkilendirme işlemini bir sürekli atama ifadesiyle ifade edelim
    assign authorized = (username == USERNAME) && (password == PASSWORD);

endmodule

## General Management System

module general_management_system(
    input [7:0] user_id,             // 8-bit kullanıcı kimliği
    input [1:0] role,                // 2-bit rol (00: User, 01: Admin, 10: Supervisor)
    input [1:0] operation,           // 2-bit işlem türü (00: Read, 01: Write, 10: Delete)
    output access_granted,           // Erişim izni
    output operation_success         // İşlem başarısı
);

    // Önceden tanımlanmış sabitler
    parameter [7:0] VALID_USER_ID = 8'hA5; // Sabit kullanıcı kimliği
    parameter [1:0] READ = 2'b00;          // Okuma işlemi
    parameter [1:0] WRITE = 2'b01;         // Yazma işlemi
    parameter [1:0] DELETE = 2'b10;        // Silme işlemi

    // Erişim kontrolü: Kullanıcı kimliği doğruysa erişim verilir
    assign access_granted = (user_id == VALID_USER_ID);

    // İşlem kontrolü: Rol ve işlem türüne göre işlem başarı durumu
    assign operation_success = access_granted && (
        (role == 2'b00 && operation == READ) ||                    // USER: Sadece okuma
        (role == 2'b01 && (operation == READ || operation == WRITE)) ||  // ADMIN: Okuma ve yazma
        (role == 2'b10)                                            // SUPERVISOR: Tüm işlemler
    );

endmodule

## Smart Lighting System

module smart_lighting_system(
    input light_sensor,            // Ortam ışık sensörü (1: karanlık, 0: aydınlık)
    input motion_sensor,           // Hareket sensörü (1: hareket var, 0: hareket yok)
    input manual_switch,           // Manuel açma-kapama düğmesi (1: açık, 0: kapalı)
    input [3:0] hour,              // Saat bilgisi (0-23 arası)
    output light                   // Işık durumu (1: açık, 0: kapalı)
);

    // Belirli saatler için zamanlayıcı sınırları
    parameter NIGHT_START = 4'd18; // Akşam 18:00
    parameter NIGHT_END = 4'd6;    // Sabah 6:00

    // Sürekli atama ifadeleri ile ışık kontrolü
    assign light = manual_switch || // Manuel düğme ışığı açar
                   (light_sensor && (motion_sensor || (hour >= NIGHT_START || hour < NIGHT_END)));

endmodule

## White Goods Control

module white_goods_control(
    input manual_laundry,           // Çamaşır makinesi manuel açma (1: açık, 0: kapalı)
    input manual_dishwasher,        // Bulaşık makinesi manuel açma (1: açık, 0: kapalı)
    input manual_oven,              // Fırın manuel açma (1: açık, 0: kapalı)
    input [3:0] hour,               // Günün saat bilgisi (0-23)
    output laundry_on,              // Çamaşır makinesi durumu
    output dishwasher_on,           // Bulaşık makinesi durumu
    output oven_on                  // Fırın durumu
);

    // Otomatik başlatma saatleri
    parameter LAUNDRY_AUTO_START = 4'd7;     // Çamaşır makinesi için otomatik başlatma saati (7:00)
    parameter DISHWASHER_AUTO_START = 4'd22; // Bulaşık makinesi için otomatik başlatma saati (22:00)
    parameter OVEN_AUTO_START = 4'd18;       // Fırın için otomatik başlatma saati (18:00)

    // Sürekli atama ifadeleri ile cihaz kontrolleri
    assign laundry_on = manual_laundry || (hour == LAUNDRY_AUTO_START);       // Çamaşır makinesi kontrolü
    assign dishwasher_on = manual_dishwasher || (hour == DISHWASHER_AUTO_START); // Bulaşık makinesi kontrolü
    assign oven_on = manual_oven || (hour == OVEN_AUTO_START);                // Fırın kontrolü

endmodule

## Smart Home Control

module smart_home_control(
    input sunlight_sensor,         // Güneş ışığı sensörü (1: güneş var, 0: güneş yok)
    input temp_sensor,             // Sıcaklık sensörü (1: sıcak, 0: soğuk)
    input air_quality_sensor,      // Hava kalitesi sensörü (1: iyi, 0: kötü)
    input manual_curtain,          // Perde manuel açma-kapama (1: açık, 0: kapalı)
    input manual_window,           // Pencere manuel açma-kapama (1: açık, 0: kapalı)
    input manual_door_lock,        // Kapı manuel kilitleme (1: kilitle, 0: aç)
    output reg curtain_open,       // Perde durumu (1: açık, 0: kapalı)
    output reg window_open,        // Pencere durumu (1: açık, 0: kapalı)
    output reg door_locked         // Kapı durumu (1: kilitli, 0: açık)
);

    // Perde Kontrolü
    always @(*) begin
        // Manuel kontrol: Kullanıcı perdeyi açmak istiyorsa
        if (manual_curtain) begin
            curtain_open = 1'b1;
        end
        // Otomatik kontrol: Güneş yoksa perdeyi aç, varsa kapat
        else if (!sunlight_sensor) begin
            curtain_open = 1'b1;  // Güneş yok, perdeyi aç
        end else begin
            curtain_open = 1'b0;  // Güneş var, perdeyi kapat
        end
    end

    // Pencere Kontrolü
    always @(*) begin
        // Manuel kontrol: Kullanıcı pencereyi açmak istiyorsa
        if (manual_window) begin
            window_open = 1'b1;
        end
        // Otomatik kontrol: Sıcaksa ve hava kalitesi iyiyse pencereyi aç
        else if (temp_sensor && air_quality_sensor) begin
            window_open = 1'b1;  // Sıcak ve hava iyi, pencereyi aç
        end else begin
            window_open = 1'b0;  // Diğer durumlarda pencereyi kapat
        end
    end

    // Kapı Kontrolü
    always @(*) begin
        // Manuel kontrol: Kullanıcı kapıyı kilitlemek istiyorsa
        if (manual_door_lock) begin
            door_locked = 1'b1;  // Kapıyı kilitle
        end else begin
            door_locked = 1'b0;  // Kapıyı aç
        end
    end

endmodule

## Climate Control System

module climate_control_system(
    input [7:0] temp,               // Sıcaklık değeri (8-bit, örneğin 0-255 arasında)
    input [7:0] humidity,           // Nem değeri (8-bit, örneğin 0-255 arasında)
    input manual_heater,            // Manuel ısıtıcı kontrolü (1: açık, 0: kapalı)
    input manual_ac,                // Manuel klima kontrolü (1: açık, 0: kapalı)
    input manual_humidifier,        // Manuel nemlendirici kontrolü (1: açık, 0: kapalı)
    input manual_dehumidifier,      // Manuel nem giderici kontrolü (1: açık, 0: kapalı)
    output heater_on,               // Isıtıcı durumu (1: açık, 0: kapalı)
    output ac_on,                   // Klima durumu (1: açık, 0: kapalı)
    output humidifier_on,           // Nemlendirici durumu (1: açık, 0: kapalı)
    output dehumidifier_on          // Nem giderici durumu (1: açık, 0: kapalı)
);

    // Sıcaklık ve nem için ideal aralıklar
    parameter [7:0] TEMP_LOW_THRESHOLD = 8'd18;      // Minimum sıcaklık (örn: 18°C)
    parameter [7:0] TEMP_HIGH_THRESHOLD = 8'd26;     // Maksimum sıcaklık (örn: 26°C)
    parameter [7:0] HUMIDITY_LOW_THRESHOLD = 8'd30;  // Minimum nem (%30)
    parameter [7:0] HUMIDITY_HIGH_THRESHOLD = 8'd

  ## AC Control

  module ac_control(
    input [7:0] temp,             // Sıcaklık değeri (8-bit, örneğin 0-255 arasında)
    input [7:0] target_temp_low,  // Hedef sıcaklık alt sınırı
    input [7:0] target_temp_high, // Hedef sıcaklık üst sınırı
    input manual_ac,              // Manuel klima kontrolü (1: açık, 0: kapalı)
    output ac_on                  // Klima durumu (1: açık, 0: kapalı)
);

    // Sürekli atama ifadeleri ile klima kontrolü
    assign ac_on = manual_ac || (temp > target_temp_high);

endmodule

  ## Heating System Control

  module heating_system_control(
    input [7:0] temp,               // Mevcut sıcaklık (8-bit)
    input [7:0] target_temp_low,    // Hedef sıcaklık alt sınırı
    input [7:0] target_temp_high,   // Hedef sıcaklık üst sınırı
    input manual_heater,            // Manuel ısıtıcı kontrolü (1: aç, 0: kapat)
    output heater_on                // Isıtıcı durumu (1: açık, 0: kapalı)
);

    // Sürekli atama ile ısıtıcı kontrolü
    assign heater_on = manual_heater || (temp < target_temp_low);

endmodule

  ## Safety System

  module SafetySystem(
    input wire motion_sensor,     // Hareket algılayıcı sinyali (1: hareket var, 0: hareket yok)
    input wire arm_system,        // Güvenlik sistemi aktiflik sinyali (1: aktif, 0: pasif)
    output wire alarm             // Alarm sinyali (1: alarm çalıyor, 0: alarm kapalı)
);

    // Sürekli atama ile alarm kontrolü
    assign alarm = arm_system && motion_sensor;

endmodule
