export function requireAuth(token: string | undefined): boolean {
  if (!token) {
    console.log("authentification failed: no token");
    return false;
  }
  return token.startsWith("valid-");
}
