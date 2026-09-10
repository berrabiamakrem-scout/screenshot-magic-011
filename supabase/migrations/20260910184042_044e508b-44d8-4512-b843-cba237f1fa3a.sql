REVOKE ALL ON FUNCTION public.rebuild_org_unit_closure() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.org_units_closure_trigger() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.set_updated_at() FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.has_role(uuid, public.app_role) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_super_admin() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.is_strategy_admin() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_access_unit(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.can_manage_unit(uuid) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.has_role(uuid, public.app_role) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_strategy_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_unit(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_manage_unit(uuid) TO authenticated;