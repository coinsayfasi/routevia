-- Ensure user_entitlements has a unique constraint on (user_id, entitlement_key)
-- so that upserts work correctly and duplicate rows are prevented.
--
-- Step 1: Deduplicate existing rows — keep the one with the latest expires_at.
-- Step 2: Add unique constraint.

-- Dedup: for each (user_id, entitlement_key) group, keep the row with max expires_at.
-- If two rows share the same max expires_at, keep the one with the latest created_at.
delete from public.user_entitlements
where id not in (
  select distinct on (user_id, entitlement_key) id
  from public.user_entitlements
  order by user_id, entitlement_key, expires_at desc nulls last, created_at desc
);

-- Add unique constraint (idempotent: skip if already exists)
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'uq_user_entitlements_user_key'
      and conrelid = 'public.user_entitlements'::regclass
  ) then
    alter table public.user_entitlements
      add constraint uq_user_entitlements_user_key
      unique (user_id, entitlement_key);
  end if;
end;
$$;
