function to_reviewlist() { window.location.href = 'list.html'; }
function to_look() { window.location.href = 'look.html'; }
function to_create() { window.location.href = 'create.html'; }


function to_change() {
    const urlParams = new URLSearchParams(window.location.search);
    const id = urlParams.get('id');
    if (id) {
        window.location.href = `change.html?id=${id}`;
    } else {
        alert("ID отзыва не найден.");
    }
}


async function deleteReview() {
    if (!confirm("Вы уверены, что хотите удалить эту рецензию?")) return;

    const urlParams = new URLSearchParams(window.location.search);
    const id = urlParams.get('id');
    if (!id) return;

    try {
        const response = await fetch(`http://localhost:3000/api/review/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            alert("Отзыв удален");
            window.location.href = 'list.html';
        } else {
            alert("Ошибка при удалении");
        }
    } catch (error) {
        console.error('Ошибка:', error);
    }
}


async function getDataFromDB(url) {
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Ошибка сети');
        return await response.json();
    } catch (error) {
        console.error('Ошибка:', error);
    }
}


// Функция для звезд
function getStars(rating) {
    if (!rating) return '';
    const num = Math.max(0, Math.min(10, parseInt(rating)));
    const star = '<span class="star-img">✨</span>';
    return star.repeat(num);
}


getDataFromDB('http://localhost:3000/api/type').then(data => {
    if (!data) return;
    const select = document.getElementById('r_type');
    if (!select) return;

    const isFilter = document.getElementById('reviews-container') !== null;
    const defaultText = isFilter ? 'Все типы' : 'Выберите тип';

    select.innerHTML = `<option value="">${defaultText}</option>`;

    data.forEach(item => {
        const option = document.createElement('option');
        option.value = item.con_type;
        option.textContent = item.con_type;
        select.appendChild(option);
    });
});


let allReviews = [];

function renderReviews(reviewsArray) {
    const container = document.getElementById('reviews-container');
    if (!container) return;

    container.innerHTML = '';

    if (reviewsArray.length === 0) {
        container.innerHTML = '<p class="null">Отзывов такого типа пока нет.</p>';
        return;
    }


    reviewsArray.forEach(item => {
        const a = document.createElement('a');
        a.href = `look.html?id=${item.id}`;
        a.className = 'clickable-block';

        let formattedDate = '';
        if (item.date) {
            const d = new Date(item.date);
            formattedDate = d.toLocaleDateString('ru-RU');
        }

        a.innerHTML = `
            <div class="content">
                <h2>${item.name}</h2>
                <p class="stars">${getStars(item.remark)}</p>
                <p class="date">${formattedDate}</p>
            </div>
        `;

        container.appendChild(a);
    });
}


function filterByType() {
    const selectedType = document.getElementById('r_type').value;
    let filteredData = allReviews;
    if (selectedType !== "") {
        filteredData = allReviews.filter(review => review.type === selectedType);
    }
    renderReviews(filteredData);
}

if (document.getElementById('reviews-container')) {
    getDataFromDB('http://localhost:3000/api/review').then(data => {
        if (!data) return;
        allReviews = data;
        filterByType();
    });
    document.getElementById('r_type').addEventListener('change', filterByType);
}


const nameElement = document.getElementById('name');
const urlParams = new URLSearchParams(window.location.search);
const reviewId = urlParams.get('id');
const isLookPage = nameElement && nameElement.tagName === 'DIV';
const isEditPage = nameElement && nameElement.tagName === 'INPUT' && reviewId;
const isCreatePage = nameElement && nameElement.tagName === 'INPUT' && !reviewId;


async function create_review() {
    if (!isCreatePage) return;

    const name = nameElement.value.trim();
    const type = document.getElementById('r_type').value;

    if (!name) { alert("Название не введено"); return; }
    if (!type) { alert("Тип не выбран"); return; }

    const newReview = {
        name: name, type: type,
        remark: parseInt(document.getElementById('remark').value),
        atmosphere: parseInt(document.getElementById('atmosphere').value),
        emotions: parseInt(document.getElementById('emotions').value),
        idea: parseInt(document.getElementById('idea').value),
        realisation: parseInt(document.getElementById('realisation').value),
        fav_char: document.getElementById('fav_char').value.trim(),
        nonfav_char: document.getElementById('nonfav_char').value.trim(),
        comment: document.getElementById('comment').value.trim()
    };

    try {
        const response = await fetch('http://localhost:3000/api/review', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(newReview)
        });

        if (response.ok) {
            alert("Отзыв успешно создан");
            window.location.href = 'list.html';
        } else {
            alert("Ошибка при создании отзыва.");
        }
    } catch (error) {
        console.error('Ошибка сети:', error);
        alert("Не удалось связаться с сервером.");
    }
}


async function loadEditData() {
    if (!isEditPage) return;

    try {
        const response = await fetch(`http://localhost:3000/api/review/${reviewId}`);
        if (!response.ok) throw new Error('Отзыв не найден');

        const data = await response.json();

        nameElement.value = data.name || '';
        document.getElementById('fav_char').value = data.fav_char || '';
        document.getElementById('nonfav_char').value = data.nonfav_char || '';
        document.getElementById('comment').value = data.comment || '';

        document.getElementById('remark').value = data.remark || 5;
        document.getElementById('atmosphere').value = data.atmosphere || 5;
        document.getElementById('emotions').value = data.emotions || 5;
        document.getElementById('idea').value = data.idea || 5;
        document.getElementById('realisation').value = data.realisation || 5;

        document.getElementById('r_type').value = data.type || '';

    } catch (error) {
        console.error('Ошибка загрузки:', error);
        alert("Не удалось загрузить данные для редактирования.");
    }
}


async function change() {
    if (!isEditPage) return;

    const updatedReview = {
        name: nameElement.value.trim(),
        type: document.getElementById('r_type').value,
        remark: parseInt(document.getElementById('remark').value),
        atmosphere: parseInt(document.getElementById('atmosphere').value),
        emotions: parseInt(document.getElementById('emotions').value),
        idea: parseInt(document.getElementById('idea').value),
        realisation: parseInt(document.getElementById('realisation').value),
        fav_char: document.getElementById('fav_char').value.trim(),
        nonfav_char: document.getElementById('nonfav_char').value.trim(),
        comment: document.getElementById('comment').value.trim()
    };

    if (!updatedReview.name) { alert("Название не может быть пустым!"); return; }
    if (!updatedReview.type) { alert("Тип не выбран!"); return; }

    try {
        const response = await fetch(`http://localhost:3000/api/review/${reviewId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updatedReview)
        });

        if (response.ok) {
            alert("Отзыв успешно изменен!");
            window.location.href = 'list.html';
        } else {
            alert("Ошибка при изменении отзыва.");
        }
    } catch (error) {
        console.error('Ошибка сети:', error);
        alert("Не удалось связаться с сервером.");
    }
}


async function loadSingleReview() {
    if (!isLookPage) return;

    if (!reviewId) {
        console.error("В ссылке нет ID отзыва!");
        alert("ID отзыва не найден. Вернитесь в список и кликните на отзыв.");
        return;
    }

    try {
        const response = await fetch(`http://localhost:3000/api/review/${reviewId}`);
        if (!response.ok) throw new Error('Отзыв не найден');

        const data = await response.json();

        nameElement.textContent = data.name || '-';
        document.getElementById('type').textContent = data.type || '-';

        document.getElementById('remark').value = data.remark || 1;
        document.getElementById('atmosphere').value = data.atmosphere || 1;
        document.getElementById('emotions').value = data.emotions || 1;
        document.getElementById('idea').value = data.idea || 1;
        document.getElementById('realisation').value = data.realisation || 1;

        document.getElementById('fav_char').textContent = data.fav_char || '-';
        document.getElementById('nonfav_char').textContent = data.nonfav_char || '-';
        document.getElementById('comment').textContent = data.comment || '-';

    } catch (error) {
        console.error('Ошибка загрузки:', error);
        alert("Не удалось загрузить данные отзыва.");
    }
}


loadEditData();
loadSingleReview();