package com.example.ecologistica

import android.Manifest
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var listener: LocationListener? = null
    private val handler = Handler(Looper.getMainLooper())
    private val timeout = Runnable { fail("NO_FIX", "No se obtuvo señal GPS. Puedes reportar sin ubicación.") }
    private val permissionCode = 7103
    private val manager: LocationManager get() = getSystemService(LOCATION_SERVICE) as LocationManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ecologistica/location")
            .setMethodCallHandler { call, result ->
                if (call.method != "currentLocation") result.notImplemented()
                else if (pending != null) result.error("BUSY", "Ya hay una solicitud GPS en curso.", null)
                else {
                    pending = result
                    if (hasPermission()) locate()
                    else requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), permissionCode)
                }
            }
    }

    private fun hasPermission() = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
        checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == permissionCode && pending != null) {
            if (hasPermission()) locate()
            else fail("PERMISSION_DENIED", "Permiso GPS denegado. Puedes reportar sin ubicación o confirmar el punto manualmente.")
        }
    }

    @Suppress("DEPRECATION")
    private fun locate() {
        try {
            val provider = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
                .firstOrNull { manager.isProviderEnabled(it) }
            if (provider == null) {
                fail("DISABLED", "La ubicación está desactivada en Android. Actívala o reporta sin GPS.")
                return
            }
            handler.postDelayed(timeout, 20000)
            // A new fix is required: a recently cached point may precede this request.
            val requestedAt = SystemClock.elapsedRealtimeNanos()
                listener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        if (location.elapsedRealtimeNanos >= requestedAt) finish(location)
                    }
                    override fun onProviderEnabled(provider: String) {}
                    override fun onProviderDisabled(provider: String) { fail("DISABLED", "GPS desactivado durante la consulta.") }
                    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
                }
                manager.requestLocationUpdates(provider, 0L, 0f, listener!!, Looper.getMainLooper())
        } catch (_: SecurityException) {
            fail("PERMISSION_DENIED", "No hay permiso de ubicación vigente. Puedes reportar sin GPS.")
        } catch (_: IllegalArgumentException) {
            fail("NO_PROVIDER", "Este dispositivo no dispone del proveedor GPS solicitado.")
        }
    }

    private fun finish(location: Location?) {
        if (location == null || !location.latitude.isFinite() || !location.longitude.isFinite() ||
            !location.hasAccuracy() || !location.accuracy.isFinite() ||
            SystemClock.elapsedRealtimeNanos() - location.elapsedRealtimeNanos > 30_000_000_000L) {
            fail("NO_FIX", "No se obtuvo una ubicación reciente con precisión conocida. Puedes reportar sin GPS.")
            return
        }
        val result = pending ?: return
        pending = null
        cleanup()
        result.success(mapOf("latitud" to location.latitude, "longitud" to location.longitude, "precision_m" to location.accuracy.toDouble()))
    }

    private fun fail(code: String, message: String) {
        val result = pending ?: return
        pending = null
        cleanup()
        result.error(code, message, null)
    }

    private fun cleanup() {
        handler.removeCallbacks(timeout)
        try { listener?.let { manager.removeUpdates(it) } } catch (_: SecurityException) { /* Permission can be revoked while pending. */ }
        listener = null
    }

    override fun onStop() {
        fail("INTERRUPTED", "La consulta GPS se interrumpió al salir de la aplicación. Reintenta estando detenido.")
        super.onStop()
    }
}
