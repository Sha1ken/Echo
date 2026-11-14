const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'db_review',
  password: process.env.DB_PASSWORD || '1234',
  port: process.env.DB_PORT || 5432,
});

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

app.get('/api/type', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, con_type FROM r_type');
    res.json(result.rows);
  } catch (err) {
    console.error('Ошибка БД:', err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

app.get('/api/review', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment, date FROM review ORDER BY date DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('Ошибка БД:', err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});


app.post('/api/review', async (req, res) => {
  try {
    const {
      name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment
    } = req.body;

    const query = `
      INSERT INTO review (
        name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING id;
    `;

    const values = [name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment];

    const result = await pool.query(query, values);
    res.status(201).json({ message: 'Отзыв создан', id: result.rows[0].id });
  } catch (err) {
    console.error('Ошибка при сохранении отзыва:', err);
    res.status(500).json({ error: 'Ошибка сервера при сохранении' });
  }
});

app.put('/api/review/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment
    } = req.body;

    const query = `
      UPDATE review
      SET name = $1, type = $2, remark = $3, atmosphere = $4, emotions = $5,
          idea = $6, realisation = $7, fav_char = $8, nonfav_char = $9, comment = $10
      WHERE id = $11
      RETURNING id;
    `;

    const values = [name, type, remark, atmosphere, emotions, idea, realisation, fav_char, nonfav_char, comment, id];

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Отзыв не найден' });
    }

    res.json({ message: 'Отзыв обновлен', id: result.rows[0].id });
  } catch (err) {
    console.error('Ошибка при обновлении:', err);
    res.status(500).json({ error: 'Ошибка сервера при обновлении' });
  }
});

app.get('/api/review/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM review WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Отзыв не найден' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Ошибка БД:', err);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});

app.delete('/api/review/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('DELETE FROM review WHERE id = $1 RETURNING id', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Отзыв не найден' });
        }

        res.json({ message: 'Отзыв успешно удален', id: result.rows[0].id });

    } catch (err) {
        console.error('Ошибка при удалении:', err);
        res.status(500).json({ error: 'Ошибка сервера при удалении' });
    }
});


app.listen(3000, () => {
  console.log('Бэк запущен на порту 3000');
});