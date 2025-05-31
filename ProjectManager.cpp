#include "ProjectManager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUuid>
#include <QDate>
#include <QDebug>

ProjectManager::ProjectManager(QObject *parent)
    : QAbstractListModel(parent)
{
    connect(&AuthManager::instance(), &AuthManager::userChanged,
            this, [this]() {
                loadFromFile();
                beginResetModel(); endResetModel();
            });
    loadFromFile();
}

int ProjectManager::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return m_projects.size();
}

QVariant ProjectManager::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_projects.size())
        return {};
    const Project &p = m_projects.at(index.row());
    switch (role) {
    case IdRole: return p.id;
    case NameRole: return p.name;
    case StatusRole: return p.status;
    case StartDateRole: return p.startDate;
    case EndDateRole: return p.endDate;
    default: return {};
    }
}

QHash<int, QByteArray> ProjectManager::roleNames() const {
    return {
        {IdRole, "id"}, {NameRole, "name"},
        {StatusRole, "status"},
        {StartDateRole, "startDate"}, {EndDateRole, "endDate"}
    };
}

void ProjectManager::createProject(const QString &name, const QString &status,
                                   const QString &startDate, const QString &endDate) {
    QDate ds = QDate::fromString(startDate, "dd.MM.yyyy");
    QDate de = QDate::fromString(endDate, "dd.MM.yyyy");
    if (!ds.isValid() || !de.isValid()) {
        qWarning() << "Invalid dates";
        return;
    }
    beginInsertRows(QModelIndex(), m_projects.size(), m_projects.size());
    m_projects.append(Project(
        QUuid::createUuid().toString(QUuid::WithoutBraces),
        name, status, startDate, endDate
        ));
    endInsertRows();
    emit projectsUpdated();
}

QString ProjectManager::fileName() const {
    if (AuthManager::instance().isAuthenticated()) {
        return QString("projects_%1.json").arg(AuthManager::instance().currentUserId());
    } else {
        return "projects_guest.json";
    }
}

void ProjectManager::loadFromFile() {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/" + fileName());
    if (!file.open(QIODevice::ReadOnly)) {
        m_projects.clear();
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    m_projects.clear();
    QJsonArray arr = doc.object().value("projects").toArray();
    for (auto v : arr) {
        auto obj = v.toObject();
        m_projects.append(Project(
            obj["id"].toString(),
            obj["name"].toString(),
            obj["status"].toString(),
            obj["startDate"].toString(),
            obj["endDate"].toString()
            ));
    }
    emit projectsUpdated();
}

void ProjectManager::saveToFile() const {
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(path);
    QFile file(path + "/" + fileName());
    if (!file.open(QIODevice::WriteOnly)) return;

    QJsonArray arr;
    for (auto &p : m_projects) {
        QJsonObject obj;
        obj["id"] = p.id;
        obj["name"] = p.name;
        obj["status"] = p.status;
        obj["startDate"] = p.startDate;
        obj["endDate"] = p.endDate;
        arr.append(obj);
    }
    QJsonObject root;
    root["projects"] = arr;
    file.write(QJsonDocument(root).toJson());
    file.close();
}

QVariantMap ProjectManager::getById(const QString &id) const {
    for (auto &p : m_projects) {
        if (p.id == id) {
            return { {"id", p.id}, {"name", p.name},
                    {"status", p.status}, {"startDate", p.startDate},
                    {"endDate", p.endDate} };
        }
    }
    return {};
}

void ProjectManager::updateStatus(const QString &id, const QString &newStatus) {
    for (int i = 0; i < m_projects.size(); ++i) {
        if (m_projects[i].id == id) {
            m_projects[i].status = newStatus;
            QModelIndex idx = createIndex(i, 0);
            emit dataChanged(idx, idx, {StatusRole});
            emit projectsUpdated();
            return;
        }
    }
}

void ProjectManager::removeProject(const QString &id) {
    for (int i = 0; i < m_projects.size(); ++i) {
        if (m_projects[i].id == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_projects.removeAt(i);
            endRemoveRows();
            emit projectsUpdated();
            return;
        }
    }
}
