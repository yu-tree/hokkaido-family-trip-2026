-- 2026-08-29: return from Otaru Station after walking through Sakaimachi and the music-box area.

update public.itinerary_items i
set place_id=p.id,
    start_time='15:50',
    travel_minutes=35,
    description='사카이마치 디저트 산책 뒤 오르골당과 주변 거리를 구경하면서 오타루역으로 걸어가요. 오타루역에서 삿포로 직통 열차를 타요.',
    fallback_note='15:50 전후 출발편을 우선 확인하고, 놓치면 역 전광판에서 다음 삿포로 직통 열차를 확인해요.'
from public.trip_days d
join public.trips t on t.id=d.trip_id
join public.places p on p.trip_id=t.id and p.name='오타루역'
where i.day_id=d.id
  and t.slug='hokkaido-family-trip-2026'
  and d.day_number=2
  and i.title='오타루에서 삿포로로 JR 이동';

