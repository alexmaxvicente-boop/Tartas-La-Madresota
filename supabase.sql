-- ============================================================
--  Tartas La Madresota — base de datos y seguridad
--  Pega TODO esto en Supabase → SQL Editor → Run.
--  Se puede correr varias veces sin romper nada.
-- ============================================================

-- ============================================================
--  0) Quién es la dueña
--  Cambia aquí el correo si algún día cambia. Es el ÚNICO
--  correo que puede modificar el contenido del sitio.
-- ============================================================
create or replace function public.es_duena()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (auth.jwt() ->> 'email') = 'yazminamoalexis@tartaslamadresota.mx',
    false
  );
$$;

-- ============================================================
--  1) Tablas
-- ============================================================

-- El contenido del sitio: una sola fila con todo.
create table if not exists public.contenido (
  id          int primary key default 1,
  datos       jsonb not null,
  actualizado timestamptz not null default now(),
  constraint contenido_una_sola_fila check (id = 1)
);

-- Los pedidos. "owner" amarra cada renglón a quien lo creó.
create table if not exists public.pedidos (
  id        bigint generated always as identity primary key,
  owner     uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  fecha     date        not null,
  cliente   text,
  tamano    text,
  cantidad  int         not null default 1,
  frutas    text[]      not null default '{}',
  total     numeric     not null default 0,
  nota      text,
  creado    timestamptz not null default now(),

  -- Límites de sanidad: cortan datos absurdos antes de que entren.
  constraint pedidos_cantidad_ok check (cantidad between 1 and 500),
  constraint pedidos_total_ok    check (total >= 0 and total <= 1000000),
  constraint pedidos_cliente_ok  check (cliente is null or char_length(cliente) <= 120),
  constraint pedidos_nota_ok     check (nota    is null or char_length(nota)    <= 500),
  constraint pedidos_frutas_ok   check (array_length(frutas, 1) is null or array_length(frutas, 1) <= 20)
);

-- Por si la tabla ya existía sin la columna owner:
alter table public.pedidos add column if not exists owner uuid default auth.uid();

create index if not exists pedidos_fecha_idx on public.pedidos (fecha desc);
create index if not exists pedidos_owner_idx on public.pedidos (owner);

-- ============================================================
--  2) Row Level Security
--  Lo aplica el servidor de Postgres. Aunque alguien tenga la
--  clave pública y llame a la API desde una terminal, estas
--  reglas se cumplen igual.
-- ============================================================

alter table public.contenido enable row level security;
alter table public.pedidos   enable row level security;

-- Nadie hereda permisos por ser "authenticated": todo pasa por política.
revoke all on public.contenido from anon, authenticated;
revoke all on public.pedidos   from anon, authenticated;
grant select on public.contenido to anon, authenticated;
grant insert, update on public.contenido to authenticated;
grant select, insert, update, delete on public.pedidos to authenticated;

-- --- CONTENIDO ---
-- Leer: cualquiera. Lo necesita la página pública para pintar el menú.
drop policy if exists "contenido lectura publica" on public.contenido;
create policy "contenido lectura publica"
  on public.contenido for select
  to anon, authenticated
  using (true);

-- Escribir: SOLO la dueña. Antes bastaba con estar logueado.
drop policy if exists "contenido escritura con sesion" on public.contenido;
drop policy if exists "contenido alta con sesion"      on public.contenido;
drop policy if exists "contenido solo la duena edita"  on public.contenido;
create policy "contenido solo la duena edita"
  on public.contenido for update
  to authenticated
  using (public.es_duena()) with check (public.es_duena());

drop policy if exists "contenido solo la duena inserta" on public.contenido;
create policy "contenido solo la duena inserta"
  on public.contenido for insert
  to authenticated
  with check (public.es_duena());

-- --- PEDIDOS ---
-- Cada quien ve y toca únicamente sus propios renglones.
drop policy if exists "pedidos ver con sesion"    on public.pedidos;
drop policy if exists "pedidos alta con sesion"   on public.pedidos;
drop policy if exists "pedidos borrar con sesion" on public.pedidos;

drop policy if exists "pedidos ver los propios" on public.pedidos;
create policy "pedidos ver los propios"
  on public.pedidos for select
  to authenticated
  using (owner = auth.uid());

drop policy if exists "pedidos alta propia" on public.pedidos;
create policy "pedidos alta propia"
  on public.pedidos for insert
  to authenticated
  with check (owner = auth.uid());

drop policy if exists "pedidos editar los propios" on public.pedidos;
create policy "pedidos editar los propios"
  on public.pedidos for update
  to authenticated
  using (owner = auth.uid()) with check (owner = auth.uid());

drop policy if exists "pedidos borrar los propios" on public.pedidos;
create policy "pedidos borrar los propios"
  on public.pedidos for delete
  to authenticated
  using (owner = auth.uid());

-- ============================================================
--  3) Almacén de fotos
--  Para que la dueña suba imágenes desde el panel sin que nadie
--  tenga que meterlas al hosting a mano.
-- ============================================================

insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do update set public = true;

-- Ver las fotos: cualquiera. Las muestra la página pública.
drop policy if exists "fotos lectura publica" on storage.objects;
create policy "fotos lectura publica"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'fotos');

-- Subir, reemplazar y borrar: solo la dueña.
drop policy if exists "fotos sube la duena" on storage.objects;
create policy "fotos sube la duena"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'fotos' and public.es_duena());

drop policy if exists "fotos reemplaza la duena" on storage.objects;
create policy "fotos reemplaza la duena"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'fotos' and public.es_duena())
  with check (bucket_id = 'fotos' and public.es_duena());

drop policy if exists "fotos borra la duena" on storage.objects;
create policy "fotos borra la duena"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'fotos' and public.es_duena());

-- ============================================================
--  4) Comprobación
--  Las dos tablas deben salir con rowsecurity = true.
-- ============================================================
select tablename, rowsecurity
from pg_tables
where schemaname = 'public' and tablename in ('contenido', 'pedidos');

-- Y estas son las políticas que quedaron activas:
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public'
order by tablename, policyname;
