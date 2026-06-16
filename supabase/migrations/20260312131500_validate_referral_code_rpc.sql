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
