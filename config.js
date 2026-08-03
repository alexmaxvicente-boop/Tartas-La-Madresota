/* ============================================================
   Configuración — Tartas La Madresota

   Este es el ÚNICO archivo con datos de conexión. Ni index.html
   ni admin.html llevan credenciales dentro.

   ------------------------------------------------------------
   IMPORTANTE, léelo una vez:

   Este sitio es estático: no hay servidor propio. Todo lo que
   ponga aquí llega al navegador del visitante y se puede leer.
   Por eso aquí SOLO van datos que pueden ser públicos.

   ✅ PUEDE ir aquí:
      · Project URL de Supabase
      · Clave "anon public"  ← está diseñada para ir en el
        navegador; es pública a propósito. Lo que protege los
        datos son las políticas RLS de supabase.sql, que las
        aplica el servidor.

   ❌ NUNCA pongas aquí:
      · La clave "service_role" de Supabase (salta TODO el RLS)
      · La contraseña de la base de datos
      · Tokens de pago, de correo o de cualquier otro servicio
      Si algo de eso hiciera falta, no puede vivir en el
      navegador: necesita un servidor o una función de Vercel.
   ------------------------------------------------------------ */

window.MADRESOTA_CONFIG = {

  /* --- Supabase (público por diseño) --- */
  supabaseUrl: "",
  supabaseKey: "",

  // El usuario del panel se vuelve correo para el login de Supabase.
  // "YazminAmoAlexis" → "yazminamoalexis@tartaslamadresota.mx"
  dominioUsuario: "tartaslamadresota.mx",


  /* --- Acceso de respaldo, solo mientras NO haya base de datos ---
     En cuanto llenes supabaseUrl y supabaseKey, el panel usa el
     login de Supabase y esto deja de tener efecto.

     Recomendación: cuando conectes la base, deja estos dos campos
     en "" para que no quede ningún rastro de contraseña en el
     código publicado. La contraseña real vivirá en Supabase, donde
     además la puedes cambiar sin tocar archivos.                  */
  usuarioLocal: "YazminAmoAlexis",
  hashLocal: "c0c8fac34d7a66b878080de37370b78b1d95d716f1dfe0c0922e0a53c370c326",
  salLocal: "madresota-2026",


  /* --- Límite de intentos de acceso (freno del navegador) --- */
  maxIntentos: 5,        // intentos antes de bloquear
  bloqueoSegundos: 60    // cuánto dura el bloqueo
};
