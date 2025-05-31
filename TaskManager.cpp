#include "TaskManager.h"
#include <QUuid>
#include <QDebug>

TaskManager::TaskManager(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&AuthManager::instance(), &AuthManager::userChanged, this, [this]() {
        loadFromFile();
        beginResetModel();
        endResetModel();
    });
    loadFromFile();
}

QString TaskManager::currentProjectId() const {
    return m_currentProjectId;
}

void TaskManager::setProjectFilter(const QString &projectId) {
    if (m_currentProjectId == projectId)
        return;
    m_currentProjectId = projectId;
    emit currentProjectIdChanged();
    beginResetModel();
    endResetModel();
}

int TaskManager::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    if (m_currentProjectId.isEmpty())
        return m_tasks.size();
    int count = 0;
    for (const auto &t : m_tasks)
        if (t.projectId == m_currentProjectId)
            ++count;
    return count;
}

QVariant TaskManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return {};

    int visible = -1;
    int realIdx = -1;
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_currentProjectId.isEmpty() || m_tasks[i].projectId == m_currentProjectId)
            ++visible;
        if (visible == index.row()) {
            realIdx = i;
            break;
        }
    }
    if (realIdx < 0)
        return {};

    const Task &t = m_tasks.at(realIdx);
    switch (role) {
    case IdRole:          return t.id;
    case ProjectIdRole:   return t.projectId;
    case NameRole:        return t.name;
    case StatusRole:      return t.status;
    case StartDateRole:   return t.startDate;
    case EndDateRole:     return t.endDate;
    default:              return {};
    }
}

QHash<int, QByteArray> TaskManager::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole]         = "id";
    roles[ProjectIdRole]  = "projectId";
    roles[NameRole]       = "name";
    roles[StatusRole]     = "status";
    roles[StartDateRole]  = "startDate";
    roles[EndDateRole]    = "endDate";
    return roles;
}

QString TaskManager::fileName() const {
    if (AuthManager::instance().isAuthenticated()) {
        return QString("tasks_%1.json").arg(AuthManager::instance().currentUserId());
    } else {
        return "tasks_guest.json";
    }
}

void TaskManager::loadFromFile() {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/" + fileName());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_tasks.clear();
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    m_tasks.clear();
    QJsonArray arr = doc.object().value("tasks").toArray();
    for (auto v : arr) {
        QJsonObject obj = v.toObject();
        m_tasks.append(Task(
            obj.value("id").toString(),
            obj.value("projectId").toString(),
            obj.value("name").toString(),
            obj.value("status").toString(),
            obj.value("startDate").toString(),
            obj.value("endDate").toString()
            ));
    }
    emit tasksUpdated();
}

void TaskManager::saveToFile() const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/" + fileName());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    QJsonArray arr;
    for (const auto &t : m_tasks) {
        QJsonObject obj;
        obj["id"] = t.id;
        obj["projectId"] = t.projectId;
        obj["name"] = t.name;
        obj["status"] = t.status;
        obj["startDate"] = t.startDate;
        obj["endDate"] = t.endDate;
        arr.append(obj);
    }
    QJsonObject root;
    root["tasks"] = arr;
    file.write(QJsonDocument(root).toJson());
    file.close();
}

void TaskManager::createTask(const QString &projectId,
                             const QString &name,
                             const QString &status,
                             const QString &startDate,
                             const QString &endDate)
{
    int nVisible = 0;
    if (m_currentProjectId.isEmpty()) {
        nVisible = m_tasks.size();
    } else {
        for (const auto &t : m_tasks) {
            if (t.projectId == m_currentProjectId)
                ++nVisible;
        }
    }

    beginInsertRows(QModelIndex(), nVisible, nVisible);
    m_tasks.append(
        Task(
            QUuid::createUuid().toString(QUuid::WithoutBraces),
            projectId,
            name,
            status,
            startDate,
            endDate
            )
        );

    endInsertRows();
    emit tasksUpdated();
}


void TaskManager::toggleStatus(const QString &taskId, const QString &newStatus) {
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_tasks[i].id == taskId) {
            m_tasks[i].status = newStatus;
            QModelIndex idx = index(i);
            emit dataChanged(idx, idx, {StatusRole});
            emit tasksUpdated();
            return;
        }
    }
}

void TaskManager::removeTask(const QString &taskId) {
    int visible = -1, realIdx = -1;
    for (int i = 0; i < m_tasks.size(); ++i) {
        if (m_currentProjectId.isEmpty() || m_tasks[i].projectId == m_currentProjectId)
            ++visible;
        if (m_tasks[i].id == taskId) {
            realIdx = i;
            break;
        }
    }
    if (realIdx < 0)
        return;
    beginRemoveRows(QModelIndex(), visible, visible);
    m_tasks.removeAt(realIdx);
    endRemoveRows();
    emit tasksUpdated();
}

void TaskManager::removeTasksByProject(const QString &projectId) {
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
        emit tasksUpdated();
    }
}
