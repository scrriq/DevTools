#include "ProjectManager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QUuid>
#include <QStandardPaths>
#include <QDir>

ProjectManager::ProjectManager(QObject *parent) : QAbstractListModel(parent) {}

int ProjectManager::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return m_projects.size();
}

QVariant ProjectManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_projects.size())
        return QVariant();

    const Project &project = m_projects[index.row()];
    switch (role) {
    case IdRole: return project.id;
    case NameRole: return project.name;
    case StatusRole: return project.status;
    case StartDateRole: return project.startDate;
    case EndDateRole: return project.endDate;
    default: return QVariant();
    }
}

QHash<int, QByteArray> ProjectManager::roleNames() const {
    return {
        {IdRole, "id"},
        {NameRole, "name"},
        {StatusRole, "status"},
        {StartDateRole, "startDate"},
        {EndDateRole, "endDate"}
    };
}

void ProjectManager::createProject(const QString &name, const QString &status,
                                   const QString &startDate, const QString &endDate) {
    // Проверка формата даты перед добавлением
    QDate start = QDate::fromString(startDate, "dd.MM.yyyy");
    QDate end = QDate::fromString(endDate, "dd.MM.yyyy");

    if (!start.isValid() || !end.isValid()) {
        qWarning() << "Некорректный формат даты! Start:" << startDate << "End:" << endDate;
        return;
    }

    qDebug() << "Создание проекта. Дата начала:" << startDate
             << "| Дата окончания:" << endDate;

    beginInsertRows(QModelIndex(), m_projects.size(), m_projects.size());
    m_projects.append(Project(
        QUuid::createUuid().toString(QUuid::WithoutBraces),
        name,
        status,
        startDate,
        endDate
        ));
    endInsertRows();
}

void ProjectManager::saveToFile(const QString &filePath) const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(".");

    QFile file(path + "/" + filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "[Ошибка] Не удалось сохранить файл:" << file.fileName();
        return;
    }

    QTextStream out(&file);
    for (const Project &project : m_projects) {
        out << project.id << "," << project.name << ","
            << project.status << "," << project.startDate << ","
            << project.endDate << "\n";
    }
    file.close();
    qDebug() << "[Успех] Проекты сохранены в:" << file.fileName();
}
void ProjectManager::loadFromFile(const QString &filePath) {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QFile file(path + "/" + filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Файл не найден:" << file.fileName();
        return;
    }

    beginResetModel();
    m_projects.clear();
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList parts = line.split(",");
        if (parts.size() == 5) {
            const QString &startDate = parts[3];
            const QString &endDate   = parts[4];

            m_projects.append(Project(parts[0], parts[1], parts[2], startDate, endDate));
            qDebug() << "Загружен проект:" << parts[1]
                     << "| Даты:" << startDate << "-" << endDate;
        }
    }
    endResetModel();
    file.close();
}
QVariantMap ProjectManager::getById(const QString &id) const {
    for (const Project &project : m_projects) {
        if (project.id == id) {
            QVariantMap map;
            map["id"] = project.id;
            map["name"] = project.name;
            map["status"] = project.status;
            map["startDate"] = project.startDate;
            map["endDate"] = project.endDate;
            return map;
        }
    }
    return QVariantMap();
}

void ProjectManager::updateStatus(const QString &id, const QString &newStatus) {
    for (int i = 0; i < m_projects.size(); ++i) {
        if (m_projects[i].id == id) {
            m_projects[i].status = newStatus;

            QModelIndex index = createIndex(i, 0);
            emit dataChanged(index, index, {StatusRole});
            return;
        }
    }
}
void ProjectManager::removeProject(const QString &id) {
    for (int row = 0; row < m_projects.size(); ++row) {
        if (m_projects[row].id == id) {
            beginRemoveRows(QModelIndex(), row, row);
            m_projects.removeAt(row);
            endRemoveRows();
            return;
        }
    }
}

