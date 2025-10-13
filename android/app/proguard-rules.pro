# Sécurité / chiffrement utilisés par flutter_secure_storage
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# (Optionnel) Conserver les annotations et signatures utiles
-keepattributes *Annotation*
-keepattributes InnerClasses,Signature,EnclosingMethod