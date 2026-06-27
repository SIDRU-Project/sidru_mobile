# Firma de release del APK Android (US-34)

Cómo se firma la app para entregar un APK/AAB instalable al jurado. **Sin secretos en este documento.**

## Qué hay versionado y qué NO
- ✅ Versionado: `android/app/build.gradle.kts` (lee la firma de `key.properties`, con fallback a debug).
- ❌ **NUNCA** versionado (gitignored): `android/key.properties` y `android/app/upload-keystore.jks`
  (cubiertos por `key.properties`, `**/*.keystore`, `**/*.jks` en `android/.gitignore`).

> Si no existe `key.properties` (p. ej. al clonar el repo o en CI sin secretos), el build cae
> automáticamente al **firmado debug**, de modo que `flutter run` sigue funcionando.

## Generar el keystore (una sola vez)
`keytool` viene con cualquier JDK. En esta máquina está en el JBR de Android Studio:
`C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.

```bash
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -storetype PKCS12 \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -dname "CN=SIDRU, OU=Capstone UPC, O=SIDRU, L=Lima, ST=Lima, C=PE"
# pedirá la contraseña del keystore (guárdala en un lugar seguro)
```

## Crear `android/key.properties`
```properties
storePassword=<la-contraseña-del-keystore>
keyPassword=<la-misma-contraseña>
keyAlias=upload
storeFile=upload-keystore.jks
```
`storeFile` es relativo al módulo `android/app`.

## Construir el entregable
```bash
# requiere JAVA_HOME apuntando a un JDK 21 (p. ej. el JBR de Android Studio)
flutter build apk --release        # -> build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release  # -> build/app/outputs/bundle/release/app-release.aab (para Play Store)
```

## Verificar que quedó firmado con la clave de release
```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
# El emisor/propietario debe ser "CN=SIDRU, OU=Capstone UPC, ..." (no "CN=Android Debug").
```

## ⚠️ Importante
- **Respalda** `upload-keystore.jks` y su contraseña fuera del repo. Si se pierden, no se podrá
  actualizar la app bajo la misma firma (para el capstone se puede regenerar otro keystore).
- La contraseña NO va en ningún archivo versionado; solo en `key.properties` (gitignored) y en tu gestor
  de secretos.
