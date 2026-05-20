import { connect } from '../db/index.js'

function normalizeBindValue(value) {
  if (value === undefined || value === null) {
    return null
  }
  if (Buffer.isBuffer(value)) {
    return value
  }
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'bigint') {
    return value
  }
  if (typeof value === 'boolean') {
    return value ? 1 : 0
  }
  return JSON.stringify(value)
}

export function selectAll() {
  const db = connect()
  const rows = db.prepare(`SELECT * FROM voice`).all()
  return rows
}

export function insert({ origin_audio_path, lang, asr_format_audio_url, reference_audio_text }) {
  const db = connect()
  const stmt = db.prepare(
    `insert into voice (origin_audio_path, lang, asr_format_audio_url, reference_audio_text, created_at)
      values (?,?,?,?,?);`
  )
  const info = stmt.run(
    normalizeBindValue(origin_audio_path),
    normalizeBindValue(lang),
    normalizeBindValue(asr_format_audio_url),
    normalizeBindValue(reference_audio_text),
    Date.now()
  )
  const id = info.lastInsertRowid
  return id
}

export function selectByID(id) {
  const db = connect()
  const stmt = db.prepare('SELECT * FROM voice WHERE id = ?')
  const row = stmt.get(id)
  return row
}
