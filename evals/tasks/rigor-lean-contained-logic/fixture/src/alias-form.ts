export function validateAlias(alias: string): boolean {
  return alias.length > 0 && alias.length <= 20;
}
