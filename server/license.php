<?php

                $conn = new mysqli('localhost', 'f0234519_base', 'ai0TPqOR', 'f0234519_base');

$PRICE = "300 RUB";
$BUYLINK = "http://vk.com/qrlk.mods";
$LASTVERSION = "0.1";
$ACTUALLINK = "http://rubbishman.ru/dev/moonloader/rtimer/!rtimer.lua";

// Decrypt Function
function mc_decrypt($decrypt, $mc_key) {
    $decoded = hex2bin($decrypt);
    $decrypted = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $mc_key, $decoded, MCRYPT_MODE_ECB);
    return $decrypted;
}

if (isset($_GET['iam'])) {
    $json = file_get_contents('http://worldtimeapi.org/api/timezone/Europe/Moscow');
    $obj = json_decode($json);
    $publickey = substr($obj->datetime, 0, 13) . "chk";
    $decrypted = mc_decrypt($_GET['iam'], $publickey);
    $keywords = preg_split("/[\s,]+/", $decrypted);

    if (isset($keywords[1]) && isset($keywords[4]) && isset($keywords[7]) && isset($keywords[10]) && isset($keywords[13]) && isset($keywords[16])) {

        $filename = mysqli_real_escape_string($conn, 'smes.csv');
        $keywords[1] = mysqli_real_escape_string($conn, $keywords[1]);
        $keywords[4] = mysqli_real_escape_string($conn, $keywords[4]);
        $keywords[7] = mysqli_real_escape_string($conn, $keywords[7]);
        $keywords[10] = mysqli_real_escape_string($conn, $keywords[10]);
        $keywords[13] = mysqli_real_escape_string($conn, $keywords[13]);
        $keywords[16] = mysqli_real_escape_string($conn, $keywords[16]);
        $keywords[18] = mysqli_real_escape_string($conn, $keywords[18]);


        $sql = "INSERT INTO smes_telemetry (Скрипт, Дата, Ник, IP, Страна, Сервер, ID_диска, moon_v, script_v, timestamp, dir) VALUES ('" . $filename . "','" . date('Y-m-d H:i:s') . "','" . $keywords[1] . "','" . $_SERVER['REMOTE_ADDR'] . "','" . geoip_country_name_by_name($_SERVER['REMOTE_ADDR']) . "','" . $keywords[4] . "','" . $keywords[16] . "','" . $keywords[13] . "','" . $keywords[10] . "','" . time() . "','" . $keywords[7] . "')";

        $query = "SELECT `Код` FROM `smes_clients` WHERE `Ник` = \"" . $keywords[1] . "\" and `Сервер` = \"" . $keywords[4] . "\"";

        $result = mysqli_fetch_array($conn->query($query));
        file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
        if (isset($result[0])) {
            $query = "SELECT `Мод` FROM `smes_clients` WHERE `Ник` = \"" . $keywords[1] . "\" and `Сервер` = \"" . $keywords[4] . "\" and `Код` = \"" . $keywords[18] . "\"";
            $mod = mysqli_fetch_array($conn->query($query));
            file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
        } else {
            $query = "SELECT `Ник` FROM `smes_clients` WHERE `Код` = \"" . $keywords[18] . "\"";
            $keys = mysqli_fetch_array($conn->query($query));
            file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
            if ($keys[0] == "-") {
                $query = "UPDATE smes_clients SET `Ник` = \"" . $keywords[1] . "\" WHERE `Код` = '" . $keywords[18] . "'";
                $conn->query($query);
                file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
                $query = "UPDATE smes_clients SET `Сервер` = \"" . $keywords[4] . "\" WHERE `Код` = '" . $keywords[18] . "'";
                $conn->query($query);
                file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
                $query = "UPDATE smes_clients SET `Дата` = \"" . date('Y-m-d H:i:s') . "\" WHERE `Код` = '" . $keywords[18] . "'";
                $conn->query($query);
                if ($keywords[4] == "185.169.134.67" or $keywords[4] == "185.169.134.68" or $keywords[4] == "185.169.134.91") {
                  $query = "UPDATE smes_clients SET `Мод` = \"evolve-rp\" WHERE `Код` = '" . $keywords[18] . "'";
                  $conn->query($query);
                }
                if ($keywords[4] == "185.169.134.20" or $keywords[4] == "185.169.134.11" or $keywords[4] == "185.169.134.34" or $keywords[4] == "185.169.134.22") {
                  $query = "UPDATE smes_clients SET `Мод` = \"samp-rp\" WHERE `Код` = '" . $keywords[18] . "'";
                  $conn->query($query);
                }
                file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
                $query = "SELECT `Код` FROM `smes_clients` WHERE `Ник` = \"" . $keywords[1] . "\" and `Сервер` = \"" . $keywords[4] . "\"";

                $result = mysqli_fetch_array($conn->query($query));
                file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
                if (isset($result[0])) {
                    $query = "SELECT `Мод` FROM `smes_clients` WHERE `Ник` = \"" . $keywords[1] . "\" and `Сервер` = \"" . $keywords[4] . "\"";
                    $mod = mysqli_fetch_array($conn->query($query));
                    file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $query . "\n", FILE_APPEND);
                }
            }
        }

        if (isset($mod[0])) {
            $sql = "INSERT INTO smes_telemetry (Скрипт, Дата, Ник, IP, Страна, Сервер, ID_диска, moon_v, script_v, timestamp, dir, sup_mode) VALUES ('" . $filename . "','" . date('Y-m-d H:i:s') . "','" . $keywords[1] . "','" . $_SERVER['REMOTE_ADDR'] . "','" . geoip_country_name_by_name($_SERVER['REMOTE_ADDR']) . "','" . $keywords[4] . "','" . $keywords[16] . "','" . $keywords[13] . "','" . $keywords[10] . "','" . time() . "','" . $keywords[7] . "','" . $mod[0] . "')";
        }

        $conn->query($sql);
        file_put_contents("license.log", date('Y-m-d H:i:s') . " - " . $sql . "\n", FILE_APPEND);
        $conn->close();
    }
}

echo "{";

if (isset($result[0])) {
    echo "\"code\": \"" . bin2hex(base64_decode(openssl_encrypt("Ok. I found you. You are: " . $keywords[1] . "* From: " . $keywords[4] . "* Mode: " . $mod[0] . "*", "AES-128-ECB", $result[0]))) . "\"";
}

echo "}";
?>
