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

export function insert({ modelName, videoPath, audioPath, voiceId }) {
  const db = connect()
  const stmt = db.prepare(
    'INSERT INTO f2f_model (name, video_path, audio_path, voice_id, created_at) VALUES (?, ?, ?, ?, ?)'
  )
  const normalizedVoiceId = Number.isFinite(Number(voiceId)) ? Number(voiceId) : null
  const info = stmt.run(
    normalizeBindValue(modelName),
    normalizeBindValue(videoPath),
    normalizeBindValue(audioPath),
    normalizeBindValue(normalizedVoiceId),
    Date.now()
  )
  return info.lastInsertRowid
}

export function selectPage({ page, pageSize, name = '' }) {
  const db = connect()
  const offset = (page - 1) * pageSize
  const rows = db
    .prepare(
      `SELECT * FROM f2f_model WHERE name like '%${name}%' ORDER BY created_at DESC LIMIT ${pageSize} OFFSET ${offset}`
    )
    .all()
  return rows
}

export function count(name = '') {
  const db = connect()
  const rows = db
    .prepare(`SELECT COUNT(*) as total FROM f2f_model WHERE name like '%${name}%'`)
    .get()
  return rows.total
}

export function selectByID(id) {
  const db = connect()
  const stmt = db.prepare('SELECT * FROM f2f_model WHERE id = ?')
  const row = stmt.get(id)
  return row
}

export function remove(id) {
  const db = connect()
  db.prepare(`DELETE FROM f2f_model WHERE id = ?`).run(id)
}