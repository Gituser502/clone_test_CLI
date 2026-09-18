/**
 * Intentionally vulnerable sample for Ox hook testing.
 * Do not use in production. Ox should flag SQL concatenation on first Write.
 */
export function loginUnsafe (email: string, password: string) {
  const q = `SELECT * FROM Users WHERE email = '${email}' AND password = '${password}'`
  return db.query(q)
}
