#include "GradientModel.h"
#include <algorithm>

GradientModel::GradientModel(QObject *parent)
    : QAbstractListModel(parent) {}

int GradientModel::rowCount(const QModelIndex &) const {
    return m_stops.size();
}

QVariant GradientModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_stops.size())
        return {};

    const auto &stop = m_stops.at(index.row());
    switch (role) {
    case Qt::UserRole + 1: return stop.color;
    case Qt::UserRole + 2: return stop.position;
    default: return {};
    }
}

QHash<int, QByteArray> GradientModel::roleNames() const {
    return {
        {Qt::UserRole + 1, "stopColor"},
        {Qt::UserRole + 2, "stopPosition"}
    };
}

void GradientModel::addStop(const QColor &color, int position) {
    beginResetModel();
    m_stops.append({color, position});
    std::sort(m_stops.begin(), m_stops.end(), [](auto &a, auto &b) {
        return a.position < b.position;
    });
    endResetModel();
    emit stopsChanged();
}

void GradientModel::removeStop(int index) {
    if (index < 0 || index >= m_stops.size()) return;
    beginResetModel();
    m_stops.removeAt(index);
    endResetModel();
    emit stopsChanged();
}

void GradientModel::updateStop(int index, const QColor &color, int position) {
    if (index < 0 || index >= m_stops.size()) return;
    beginResetModel();
    m_stops[index].color = color;
    m_stops[index].position = position;
    std::sort(m_stops.begin(), m_stops.end(), [](auto &a, auto &b) {
        return a.position < b.position;
    });
    endResetModel();
    emit stopsChanged();
}

void GradientModel::updateStop(int index, const QString &colorName, int position) {
    QColor c(colorName);
    // Проверяем, что цвет корректен
    if (!c.isValid() || index < 0 || index >= m_stops.size())
        return;
    // Внутри перенаправляем на основную реализацию
    updateStop(index, c, position);
}

GradientModel::GradientType GradientModel::gradientType() const { return m_type; }
int GradientModel::angle() const { return m_angle; }
QColor GradientModel::currentColor() const { return m_currentColor; }

void GradientModel::setGradientType(GradientType type) {
    if (m_type == type) return;
    m_type = type;
    emit gradientTypeChanged();
}

void GradientModel::setAngle(int angle) {
    if (m_angle == angle) return;
    m_angle = angle;
    emit angleChanged();
}

void GradientModel::setCurrentColor(const QColor &color) {
    if (m_currentColor == color) return;
    m_currentColor = color;
    emit currentColorChanged();
}


QVariantList GradientModel::stopsList() const {
    QVariantList list;
    for (const auto &stop : m_stops) {
        QVariantMap m;
        m["color"]    = stop.color;
        m["position"] = stop.position;
        list.append(m);
    }
    return list;
}
