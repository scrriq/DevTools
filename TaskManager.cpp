#include "TaskManager.h"
#include <QFile>
#include <QTextStream>
#include <QUuid>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

TaskManager::TaskManager(QObject *parent)
    : QAbstractListModel(parent)
{}

int TaskManager::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    if (m_currentProjectId.isEmpty())
        return m_tasks.size();

    return std::count_if(m_tasks.begin(), m_tasks.end(), [this](const Task &task) {
        return task.projectId == m_currentProjectId;
    });
}


QVariant TaskManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return {};

    int visibleIndex = -1;
    int filteredIndex = -1;

    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_currentProjectId.isEmpty() || m_tasks[i].projectId == m_currentProjectId)
            ++visibleIndex;

        if (visibleIndex == index.row()) {
            filteredIndex = i;
            break;
        }
    }

    if (filteredIndex < 0 || filteredIndex >= m_tasks.size())
        return {};

    const Task &t = m_tasks[filteredIndex];
    switch (role) {
    case IdRole: return t.id;
    case ProjectIdRole: return t.projectId;
    case NameRole: return t.name;
    case StatusRole: return t.status;
    case StartDateRole: return t.startDate;
    case EndDateRole: return t.endDate;
    default: return {};
    }
}


QHash<int, QByteArray> TaskManager::roleNames() const {
    return {
        {IdRole,        "id"},
        {ProjectIdRole, "projectId"},
        {NameRole,      "name"},
        {StatusRole,    "status"},
        {StartDateRole, "startDate"},
        {EndDateRole,   "endDate"}
    };
}

void TaskManager::createTask(const QString &projectId,
                             const QString &name,
                             const QString &status,
                             const QString &startDate,
                             const QString &endDate)
{
    beginInsertRows({}, m_tasks.size(), m_tasks.size());
    m_tasks.append(Task(
        QUuid::createUuid().toString(QUuid::WithoutBraces),
        projectId,
        name,
        status,
        startDate,
        endDate
        ));
    endInsertRows();
}

void TaskManager::toggleStatus(const QString &taskId, const QString &newStatus) {
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_tasks[i].id == taskId) {
            m_tasks[i].status = newStatus;
            QModelIndex idx = index(i);
            emit dataChanged(idx, idx, {StatusRole});
            break;
        }
    }
}

void TaskManager::loadFromFile(const QString &filePath) {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QFile file(path + "/" + filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Tasks file not found:" << file.fileName();
        return;
    }
    beginResetModel();
    m_tasks.clear();
    QTextStream in(&file);
    while (!in.atEnd()) {
        auto parts = in.readLine().split(",");
        if (parts.size() == 6) {
            m_tasks.append(Task(parts[0], parts[1], parts[2],
                                parts[3], parts[4], parts[5]));
        }
    }
    endResetModel();
}

void TaskManager::saveToFile(const QString &filePath) const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path); if (!dir.exists()) dir.mkpath(".");
    QFile file(path + "/" + filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Cannot save tasks:" << file.fileName();
        return;
    }
    QTextStream out(&file);
    for (auto &t : m_tasks) {
        out << t.id << ","
            << t.projectId << ","
            << t.name << ","
            << t.status << ","
            << t.startDate << ","
            << t.endDate << "\n";
    }
    file.close();
}

QString TaskManager::currentProjectId() const {
    return m_currentProjectId;
}

void TaskManager::setProjectFilter(const QString &projectId) {

    m_currentProjectId = projectId;
    emit currentProjectIdChanged();

    beginResetModel();
    endResetModel();
}

void TaskManager::removeTask(const QString &taskId) {
    // ищем не в полном списке, а в *фильтрованном представлении*
    int viewRow = -1, visibleIndex = -1;
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_currentProjectId.isEmpty() || m_tasks[i].projectId == m_currentProjectId)
            ++visibleIndex;
        if (m_tasks[i].id == taskId) {
            viewRow = visibleIndex;
            m_tasks.removeAt(i);
            break;
        }
    }
    if (viewRow >= 0) {
        beginRemoveRows(QModelIndex(), viewRow, viewRow);
        endRemoveRows();
    }
}

// удаление всех задач проекта вместе с проектом
Q_INVOKABLE void TaskManager::removeTasksByProject(const QString &projectId) {
    bool removed = false;
    for (int i = m_tasks.size() - 1; i >= 0; --i) {
        if (m_tasks[i].projectId == projectId) {
            m_tasks.removeAt(i);
            removed = true;
        }
    }
    if (removed) {
        beginResetModel();
        endResetModel();
    }
}

