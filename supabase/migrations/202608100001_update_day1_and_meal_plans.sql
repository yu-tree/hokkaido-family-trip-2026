-- 2026-08-10 planning update: confirmed sushi, jingisukan shortlist,
-- soup-curry alternatives, and the Day 1 Biei route.

-- DAY 1: visit the time-limited flower garden first, then Blue Pond in daylight.
update public.itinerary_items i
set sort_order = case
      when i.title like '%시키사이노오카%' then 20
      when i.title like '%청의호수%' then 30
      when i.title like '%흰수염폭포%' then 40
      else i.sort_order
    end
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 1
  and (i.title like '%시키사이노오카%' or i.title like '%청의호수%' or i.title like '%흰수염폭포%');

update public.itinerary_items i
set sort_order = 2,
    start_time = '16:00',
    travel_minutes = 145,
    stay_minutes = 55,
    status = 'confirmed',
    description = '17:30 마감 전에 꽃밭을 먼저 둘러보고 감자고로케·멜론·소프트크림으로 쉬어가요.',
    fallback_note = '16:35 이후 도착하면 산책 범위를 줄이고 간식은 포장해요.',
    is_published = true
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 1
  and i.title like '%시키사이노오카%';

update public.itinerary_items i
set sort_order = 3,
    start_time = '17:20',
    travel_minutes = 25,
    stay_minutes = 25,
    status = 'confirmed',
    description = '일몰 18:13 전의 자연광이 남아 있을 때 산책하고 가족사진을 남겨요.',
    fallback_note = '날씨가 흐리거나 일정이 늦으면 15분만 핵심 산책로를 보고 바로 삿포로로 출발해요.',
    is_published = true
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 1
  and i.title like '%청의호수%';

update public.itinerary_items i
set status = 'skipped', is_published = false
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 1
  and i.title like '%흰수염폭포%';

-- DAY 2 lunch: 13:00 confirmed, 12:30 change requested through Instagram DM.
update public.itinerary_items i
set start_time = '13:00',
    stay_minutes = 75,
    status = 'confirmed',
    description = '스시 나카무라에서 4명이 점심을 먹어요. 현재 13:00 예약 확정이며 12:30으로 변경을 요청해 둔 상태예요.',
    reservation_required = true
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 2
  and i.title like '%스시 나카무라%';

update public.reservations r
set provider = '스시 나카무라 · Instagram DM',
    status = 'booked',
    due_date = '2026-08-29',
    public_note = '8월 29일 13:00 · 4명 예약 확정 · 12:30 변경 조율 중',
    updated_at = now()
from public.trips t
where r.trip_id = t.id
  and t.slug = 'hokkaido-family-trip-2026'
  and r.title = '스시 나카무라 점심';

insert into public.reservation_private (reservation_id, private_note)
select r.id, 'Instagram DM으로 13:00, 4명 예약 확정. 저녁 식사와의 간격을 위해 12:30으로 변경 요청했으며 답변 대기 중.'
from public.reservations r
join public.trips t on t.id = r.trip_id
where t.slug = 'hokkaido-family-trip-2026' and r.title = '스시 나카무라 점심'
on conflict (reservation_id) do update
set private_note = excluded.private_note;

-- DAY 2 dinner: first choice is Yuuhi; booking is still being coordinated.
insert into public.places
  (trip_id, name, category, map_url, booking_url, candidate_status, tags, public_tip)
select id, '극미염숙성 징기스칸 유우히 스스키노 본점', 'restaurant',
  'https://www.google.com/maps/search/?api=1&query=%E6%A5%B5%E3%81%BF%E5%A1%A9%E7%86%9F%E6%88%90%E3%82%B8%E3%83%B3%E3%82%AE%E3%82%B9%E3%82%AB%E3%83%B3%E3%82%86%E3%81%86%E3%81%B2%E3%81%99%E3%81%99%E3%81%8D%E3%81%AE',
  'tel:+81115966922', 'candidate', array['징기스칸','1순위','전화예약'],
  '소금 숙성 양고기를 맛보는 1순위 저녁 후보예요.'
from public.trips where slug = 'hokkaido-family-trip-2026'
on conflict (trip_id, name) do update set
  booking_url = excluded.booking_url, candidate_status = excluded.candidate_status,
  tags = excluded.tags, public_tip = excluded.public_tip;

insert into public.places
  (trip_id, name, category, map_url, candidate_status, tags, public_tip)
select t.id, v.name, 'restaurant', v.map_url, v.status, v.tags, v.tip
from public.trips t cross join (values
  ('징기스칸 요하치 삿포로 본점','https://www.google.com/maps/search/?api=1&query=%E3%82%B8%E3%83%B3%E3%82%AE%E3%82%B9%E3%82%AB%E3%83%B3%E9%99%BD%E5%85%AB%E6%9C%AD%E5%B9%8C%E6%9C%AC%E5%BA%97','candidate',array['징기스칸','후순위'],'17:30만 남아 있어 현재 일정에는 이른 후보예요.'),
  ('홋카이도 징기스칸 마사진 스스키노 본점','https://www.google.com/maps/search/?api=1&query=%E5%8C%97%E6%B5%B7%E9%81%93%E3%82%B8%E3%83%B3%E3%82%AE%E3%82%B9%E3%82%AB%E3%83%B3%E3%83%9E%E3%82%B5%E3%82%B8%E3%83%B3%E3%81%99%E3%81%99%E3%81%8D%E3%81%AE%E6%9C%AC%E5%BA%97','excluded',array['징기스칸','예약마감'],'현재 예약이 마감되어 제외한 후보예요.'),
  ('탄야키 징기스칸 키타노카제','https://www.google.com/maps/search/?api=1&query=%E7%82%AD%E7%84%BC%E3%82%B8%E3%83%B3%E3%82%AE%E3%82%B9%E3%82%AB%E3%83%B3%E5%8C%97%E3%81%AE%E9%A2%A8','candidate',array['징기스칸','예약가능','대안'],'예약 가능한 대안으로 보관해 둬요.')
) as v(name,map_url,status,tags,tip)
where t.slug = 'hokkaido-family-trip-2026'
on conflict (trip_id, name) do update set
  map_url = excluded.map_url, candidate_status = excluded.candidate_status,
  tags = excluded.tags, public_tip = excluded.public_tip;

update public.itinerary_items i
set place_id = p.id,
    start_time = '20:30',
    title = '징기스칸 저녁',
    description = '20:30 식사를 목표로 1순위 유우히 스스키노 본점에 예약을 문의 중이에요.',
    status = 'planned',
    reservation_required = true,
    fallback_note = '유우히 예약이 어렵다면 예약 가능한 키타노카제로 변경해요.'
from public.trip_days d
join public.trips t on t.id = d.trip_id
join public.places p on p.trip_id = t.id and p.name = '극미염숙성 징기스칸 유우히 스스키노 본점'
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 2
  and i.title like '%징기스칸%';

update public.reservations r
set provider = '극미염숙성 징기스칸 유우히 스스키노 본점',
    status = 'considering',
    due_date = '2026-08-29',
    booking_url = 'tel:+81115966922',
    public_note = '8월 29일 20:30 · 4명 전화 예약 문의 중',
    updated_at = now()
from public.trips t
where r.trip_id = t.id
  and t.slug = 'hokkaido-family-trip-2026'
  and r.title = '징기스칸 저녁';

insert into public.reservation_private (reservation_id, contact_phone, private_note)
select r.id, '유우히 011-596-6922',
  '1순위 유우히: 일본어 가능한 지인에게 8/29 20:30, 4명 전화 문의를 부탁한 상태. 2순위 키타노카제는 예약 가능. 요하치는 17:30만 남아 후순위. 마사진은 예약 마감.'
from public.reservations r
join public.trips t on t.id = r.trip_id
where t.slug = 'hokkaido-family-trip-2026' and r.title = '징기스칸 저녁'
on conflict (reservation_id) do update
set contact_phone = excluded.contact_phone,
    private_note = excluded.private_note;

insert into public.trip_tasks
  (trip_id, itinerary_item_id, task_type, title, details, inquiry_script, fallback_plan, action_url, due_date, priority, sort_order)
select t.id, i.id, 'reservation', '유우히 징기스칸 전화 예약 결과 확인',
  '지인에게 부탁한 8월 29일 20:30, 4명 예약 문의 결과를 확인해요.',
  '8月29日（土）20時30分に4名で予約できますか。テーブル席を希望します。',
  '예약이 어렵다면 키타노카제의 20:30 전후 좌석을 바로 예약해요.',
  'tel:+81115966922', '2026-08-20', 'critical', 25
from public.trips t
join public.trip_days d on d.trip_id = t.id and d.day_number = 2
join public.itinerary_items i on i.day_id = d.id and i.title = '징기스칸 저녁'
where t.slug = 'hokkaido-family-trip-2026'
  and not exists (
    select 1 from public.trip_tasks x
    where x.trip_id = t.id and x.title = '유우히 징기스칸 전화 예약 결과 확인'
  );

-- DAY 3 lunch: Odori choices first; airport shops are a timing fallback.
insert into public.places
  (trip_id, name, category, map_url, candidate_status, tags, public_tip)
select t.id, v.name, 'restaurant', v.map_url, 'candidate', v.tags, v.tip
from public.trips t cross join (values
  ('Suage+','https://www.google.com/maps/search/?api=1&query=Soup+Curry+Suage%2B+Sapporo',array['수프카레','오도리','예약불가'],'11시대에 일찍 가면 좋은 오도리·스스키노 후보예요.'),
  ('스프카레 GARAKU 삿포로 본점','https://www.google.com/maps/search/?api=1&query=Soup+Curry+GARAKU+Sapporo',array['수프카레','오도리'],'웨이팅을 확인해 고를 오도리 후보예요.'),
  ('Soup Curry BAR DAN','https://www.google.com/maps/search/?api=1&query=Soup+Curry+BAR+DAN+Sapporo',array['수프카레','오도리'],'당일 대기 상황을 보고 고를 후보예요.'),
  ('스프카레 GARAKU 신치토세공항점','https://www.google.com/maps/search/?api=1&query=Soup+Curry+GARAKU+New+Chitose+Airport',array['수프카레','공항','대안'],'시내 일정이 늦어졌을 때 공항에서 먹는 대안이에요.'),
  ('스프카레 라쿄 신치토세공항점','https://www.google.com/maps/search/?api=1&query=Soup+Curry+Rakkyo+New+Chitose+Airport',array['수프카레','공항','대안'],'공항 국내선 3층의 대안이에요.')
) as v(name,map_url,tags,tip)
where t.slug = 'hokkaido-family-trip-2026'
on conflict (trip_id, name) do update set
  map_url = excluded.map_url, candidate_status = 'candidate', tags = excluded.tags, public_tip = excluded.public_tip;

update public.itinerary_items i
set start_time = '11:00',
    title = '오도리 수프카레 점심',
    description = '오도리에서 Suage+·GARAKU·BAR DAN의 대기를 비교해 11시대에 일찍 먹어요.',
    stay_minutes = 65,
    fallback_note = '시내 일정이 늦으면 바로 공항으로 이동해 국내선 3층 GARAKU 또는 라쿄에서 먹어요.'
from public.trip_days d
join public.trips t on t.id = d.trip_id
where i.day_id = d.id
  and t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 3
  and i.title like '%수프카레%';

insert into public.place_options (itinerary_item_id, place_id, option_type, sort_order, public_tip)
select i.id, p.id, 'alternative', v.ord, p.public_tip
from public.itinerary_items i
join public.trip_days d on d.id = i.day_id
join public.trips t on t.id = d.trip_id
cross join (values
  ('Suage+',1),('스프카레 GARAKU 삿포로 본점',2),('Soup Curry BAR DAN',3),
  ('스프카레 GARAKU 신치토세공항점',4),('스프카레 라쿄 신치토세공항점',5)
) v(name,ord)
join public.places p on p.trip_id = t.id and p.name = v.name
where t.slug = 'hokkaido-family-trip-2026'
  and d.day_number = 3
  and i.title = '오도리 수프카레 점심'
on conflict (itinerary_item_id, place_id) do update
set sort_order = excluded.sort_order, public_tip = excluded.public_tip;
