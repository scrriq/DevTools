#pragma once
#include <QAbstractListModel>
#include <QDate>
#include <vector>
#include "devtools.h"

struct ProjectModelEntry {
    QString name;
    QDate startDate;
    QDate endDate;
    DevTools::State state;
};

class ProjectModel : public QAbstractListModel {
    Q_OBJECT
public:
    enum Roles { NameRole = Qt::UserRole + 1, StartRole, EndRole, StateRole };
    explicit ProjectModel(QObject* parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE void createProject(const QString &name, const QDate &start, const QDate &end);
private:
    std::vector<ProjectModelEntry> m_projects;
};
