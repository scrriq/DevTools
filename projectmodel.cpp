#include "projectmodel.h"

ProjectModel::ProjectModel(QObject* parent) : QAbstractListModel(parent) {}

int ProjectModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return static_cast<int>(m_projects.size());
}

QVariant ProjectModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) return {};
    const auto &p = m_projects[index.row()];
    switch (role) {
    case NameRole:  return p.name;
    case StartRole: return p.startDate;
    case EndRole:   return p.endDate;
    case StateRole: return QVariant::fromValue(p.state);
    default:        return {};
    }
}

QHash<int, QByteArray> ProjectModel::roleNames() const {
    return {{NameRole, "name"}, {StartRole, "startDate"}, {EndRole, "endDate"}, {StateRole, "state"}};
}

void ProjectModel::createProject(const QString &name, const QDate &start, const QDate &end) {
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_projects.push_back({name, start, end, DevTools::State::NotStated});
    endInsertRows();
}
