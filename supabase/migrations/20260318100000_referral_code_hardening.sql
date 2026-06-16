-- Referral code hardening:
-- 1. Auto-generate referral_code on every new profile row (trigger)
-- 2. Backfill existing profiles that have null referral_code
-- 3. Fix validate_referral_code RPC to also check code format consistently

-- Trigger function: assign a unique referral code before INSERT
create or replace function public.trg_auto_referral_code()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_exists int;
begin
  if new.referral_code is null then
    loop
      v_code := upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));
      select count(*) into v_exists from public.profiles where referral_code = v_code;
      exit when v_exists = 0;
    end loop;
    new.referral_code := v_code;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_auto_referral_code on public.profiles;
create trigger trg_auto_referral_code
before insert on public.profiles
for each row execute function public.trg_auto_referral_code();

-- Backfill: assign referral codes to existing profiles that don't have one
do $$
declare
  r record;
  v_code text;
  v_exists int;
begin
  for r in select id from public.profiles where referral_code is null loop
    loop
      v_code := upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));
      select count(*) into v_exists from public.profiles where referral_code = v_code;
      exit when v_exists = 0;
    end loop;
    update public.profiles set referral_code = v_code where id = r.id;
  end loop;
end;
$$;

-- Tighten validate_referral_code: must be exactly 8 uppercase alphanumeric chars
create or replace function public.validate_referral_code(p_code text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text := upper(trim(coalesce(p_code, '')));
begin
  if v_code !~ '^[A-Z0-9]{8}$' then
    return false;
  end if;

  return exists(
    select 1
    from public.profiles
    where referral_code = v_code
  );
end;
$$;

grant execute on function public.validate_referral_code(text) to anon, authenticated, service_role;
