insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'reservation-documents',
  'reservation-documents',
  false,
  20971520,
  array['application/pdf', 'image/png', 'image/jpeg']
)
on conflict (id) do update
set public = false,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "reservation documents admin read" on storage.objects;
create policy "reservation documents admin read"
on storage.objects for select
to authenticated
using (
  bucket_id = 'reservation-documents'
  and exists (
    select 1
    from public.admin_allowlist a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  )
);

drop policy if exists "reservation documents admin insert" on storage.objects;
create policy "reservation documents admin insert"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'reservation-documents'
  and exists (
    select 1
    from public.admin_allowlist a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  )
);

drop policy if exists "reservation documents admin update" on storage.objects;
create policy "reservation documents admin update"
on storage.objects for update
to authenticated
using (
  bucket_id = 'reservation-documents'
  and exists (
    select 1
    from public.admin_allowlist a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  )
)
with check (
  bucket_id = 'reservation-documents'
  and exists (
    select 1
    from public.admin_allowlist a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  )
);

drop policy if exists "reservation documents admin delete" on storage.objects;
create policy "reservation documents admin delete"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'reservation-documents'
  and exists (
    select 1
    from public.admin_allowlist a
    where lower(a.email) = lower(auth.jwt() ->> 'email')
  )
);
