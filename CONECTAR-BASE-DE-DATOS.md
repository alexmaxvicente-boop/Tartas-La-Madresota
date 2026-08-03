# Conectar la base de datos (para que el panel guarde en vivo)

Ahora mismo el sitio funciona en **modo archivo**: el panel guarda en el dispositivo
y hay que subir `datos.json` a mano. Siguiendo estos pasos pasa a **modo en vivo**:
la dueña cambia un precio y en 2 segundos ya se ve en internet.

Es gratis. Toma unos 10 minutos y se hace una sola vez.

---

## 1. Crear el proyecto

1. Entra a **supabase.com** y crea una cuenta (sirve con la de Google).
2. Botón **New project**.
   - Name: `tartas-la-madresota`
   - Database Password: la que quieras, **guárdala** (no es la del panel).
   - Region: elige la más cercana a México (por ejemplo *East US*).
3. Espera 1–2 minutos a que termine de crearse.

---

## 2. Crear las tablas

1. En el menú de la izquierda: **SQL Editor** → **New query**.
2. Abre el archivo `supabase.sql` de esta carpeta, copia **todo** su contenido y pégalo.
3. Botón **Run**.

Al final debe aparecer una tabla diciendo `contenido` y `pedidos` con
`rowsecurity = true`. Eso confirma que la protección quedó activa.

---

## 3. Crear el usuario de la dueña

1. Menú izquierdo: **Authentication** → **Users** → **Add user** → *Create new user*.
2. Llena así:
   - Email: `yazminamoalexis@tartaslamadresota.mx`
   - Password: `Yazmin040604`
   - Marca **Auto Confirm User** (importante, si no no podrá entrar).
3. **Create user**.

> El correo es solo interno; no tiene que existir de verdad. En el panel ella
> seguirá escribiendo únicamente `YazminAmoAlexis`.

Para cambiar la contraseña en el futuro se hace desde aquí mismo, sin tocar el código.

---

## 4. Pegar las dos claves

1. Menú izquierdo: **Settings** (engrane) → **API**.
2. Copia estos dos valores:
   - **Project URL**
   - **anon public** (la clave larga)
3. Ábre el archivo `config.js` de esta carpeta y pégalos:

```js
window.MADRESOTA_CONFIG = {
  supabaseUrl: "https://xxxxxxxxxxxx.supabase.co",
  supabaseKey: "eyJhbGciOi...(la clave larga)",
  dominioUsuario: "tartaslamadresota.mx"
};
```

4. Sube al sitio los archivos: `config.js`, `admin.html`, `index.html`,
   `datos.json` y `supabase.sql` no hace falta subirlo.

---

## 5. Primera entrada

Abre `tudominio/admin.html` y entra con el usuario y contraseña.

La primera vez el panel detecta que la base está vacía y **sube solo** el contenido
actual desde `datos.json`. De ahí en adelante todo queda en la base de datos.

En la pestaña **Publicar** debe decir *"Conectado a la base de datos"*.

---

## Qué cambia una vez conectado

| | Antes | Después |
|---|---|---|
| Cambiar un precio | Descargar y subir archivo | Se ve al instante |
| Contraseña | En el código (débil) | La valida el servidor |
| Pedidos y reportes | Solo en ese dispositivo | Desde cualquier celular |
| Fotos nuevas | Subirlas a `img/` | Igual, subirlas a `img/` |

## Lo que sigue igual

- **Las fotos** se siguen subiendo a mano a la carpeta `img/`. El panel te las deja
  recortadas y comprimidas, pero hay que subirlas.
- **Los pedidos los sigue registrando ella.** WhatsApp manda el mensaje del celular
  del cliente directo a su teléfono, sin pasar por el sitio; no hay forma de
  capturarlo automáticamente.

## Si algo sale mal

El sitio **no se rompe**. Si la base falla o las claves están mal, la página usa
`datos.json`, y si ese tampoco está, usa los datos que trae dentro. El cliente
siempre ve el menú.

Si el panel dice *"No se pudo conectar con la base de datos"*:
- Revisa que las dos claves de `config.js` estén completas.
- Revisa que el SQL del paso 2 haya corrido sin errores.

Si dice *"Usuario o contraseña incorrectos"* pero son correctos: casi siempre es
que faltó marcar **Auto Confirm User** en el paso 3.
