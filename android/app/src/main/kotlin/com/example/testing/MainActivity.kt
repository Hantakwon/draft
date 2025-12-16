package com.example.testing

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.util.Base64
import android.util.Log
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import android.content.pm.PackageInfo

// (로그를 명확히 하기 위해 태그를 클래스 상수로 정의)
private const val TAG = "KAKAO_KEY_HASH"

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Flutter 엔진 실행 코드 전에 키 해시 함수 호출
        getAppKeyHash()
    }

    /**
     * Kakao Developers 등록을 위한 디버그 키 해시를 계산하여 Logcat에 출력합니다.
     */
    private fun getAppKeyHash() {
        try {
            // GET_SIGNATURES는 Android 9 이하에서만 권장되지만, 디버그 해시를 얻기 위해 사용합니다.
            val info: PackageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)

            // 🚨 오류 해결: info.signatures가 null이 아닐 때만 실행하도록 ?.let을 사용합니다.
            info.signatures?.let { signatures ->
                for (signature in signatures) {
                    val md: MessageDigest = MessageDigest.getInstance("SHA")
                    md.update(signature.toByteArray())
                    val keyHash = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                    Log.d(TAG, "Key Hash !!!!!!!!!!!!!!!!!!!! : $keyHash") // 👈 이 값을 복사하세요.
                }
            } ?: Log.e(TAG, "Signatures list is null.") // signatures가 null일 경우 로그

        } catch (e: PackageManager.NameNotFoundException) {
            Log.e(TAG, "NameNotFoundException: ${e.message}")
        } catch (e: NoSuchAlgorithmException) {
            Log.e(TAG, "NoSuchAlgorithmException: ${e.message}")
        }
    }
}