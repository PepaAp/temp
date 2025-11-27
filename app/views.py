import calendar

from flask_appbuilder import ModelView, IndexView
from flask_appbuilder.charts.views import GroupByChartView
from flask_appbuilder.models.group import aggregate_count
from flask_appbuilder.models.sqla.interface import SQLAInterface

from . import appbuilder, db
from .models import Contact, ContactGroup, Gender, vyrobek, Sklad


class MyIndexView(IndexView):
    index_template = 'index.html'


# Nastavení vlastní úvodní stránky
appbuilder.indexview = MyIndexView


def fill_gender():
    try:
        db.session.add(Gender(name="Male"))
        db.session.add(Gender(name="Female"))
        db.session.commit()
    except Exception:
        db.session.rollback()


class VyrobekModelView(ModelView):
    datamodel = SQLAInterface(vyrobek)
    list_columns = ["nazev", "serial_number"]
    label_columns = {"nazev": "Název produktu", "serial_number": "Sériové číslo"}
    description_columns = {
        "nazev": "Název výrobku v inventáři",
        "serial_number": "Unikátní sériové číslo produktu"
    }
    show_template = "appbuilder/general/model/show_cascade.html"
    edit_template = "appbuilder/general/model/edit_cascade.html"

class SkladModelView(ModelView):
    datamodel = SQLAInterface(Sklad)
    list_columns = ["nazev", "datum", "ks", "stav"]
    label_columns = {
        "nazev": "Název skladu", 
        "datum": "Datum", 
        "ks": "Počet kusů", 
        "stav": "Stav"
    }
    description_columns = {
        "nazev": "Název skladu nebo lokace",
        "datum": "Datum poslední aktualizace",
        "ks": "Aktuální počet kusů na skladě",
        "stav": "Současný stav skladu"
    }
    show_template = "appbuilder/general/model/show_cascade.html"
    edit_template = "appbuilder/general/model/edit_cascade.html"
    base_order = ("datum", "desc")

appbuilder.add_view(
    VyrobekModelView, "Seznam výrobků", icon="fa-cube", category="📦 Výrobky",
    category_icon="fa-cubes"
)

appbuilder.add_view(
    SkladModelView, "Seznam skladů", icon="fa-warehouse", category="🏭 Sklady",
    category_icon="fa-building"
)    

class ContactModelView(ModelView):
    datamodel = SQLAInterface(Contact)

    list_columns = ["name", "personal_celphone", "birthday", "contact_group.name"]
    
    label_columns = {
        "name": "Jméno",
        "personal_celphone": "Mobilní telefon",
        "birthday": "Datum narození",
        "contact_group": "Skupina",
        "gender": "Pohlaví",
        "address": "Adresa",
        "personal_phone": "Telefon"
    }

    base_order = ("name", "asc")
    show_fieldsets = [
        ("Shrnutí", {"fields": ["name", "gender", "contact_group"]}),
        (
            "Osobní informace",
            {
                "fields": [
                    "address",
                    "birthday",
                    "personal_phone",
                    "personal_celphone",
                ],
                "expanded": False,
            },
        ),
    ]

    add_fieldsets = [
        ("Shrnutí", {"fields": ["name", "gender", "contact_group"]}),
        (
            "Osobní informace",
            {
                "fields": [
                    "address",
                    "birthday",
                    "personal_phone",
                    "personal_celphone",
                ],
                "expanded": False,
            },
        ),
    ]

    edit_fieldsets = [
        ("Shrnutí", {"fields": ["name", "gender", "contact_group"]}),
        (
            "Osobní informace",
            {
                "fields": [
                    "address",
                    "birthday",
                    "personal_phone",
                    "personal_celphone",
                ],
                "expanded": False,
            },
        ),
    ]


class GroupModelView(ModelView):
    datamodel = SQLAInterface(ContactGroup)
    related_views = [ContactModelView]
    label_columns = {"name": "Název skupiny"}


def pretty_month_year(value):
    return calendar.month_name[value.month] + " " + str(value.year)


def pretty_year(value):
    return str(value.year)


class ContactTimeChartView(GroupByChartView):
    datamodel = SQLAInterface(Contact)

    chart_title = "Statistika narozenin kontaktů"
    chart_type = "AreaChart"
    label_columns = ContactModelView.label_columns
    definitions = [
        {
            "group": "month_year",
            "formatter": pretty_month_year,
            "series": [(aggregate_count, "group")],
        },
        {
            "group": "year",
            "formatter": pretty_year,
            "series": [(aggregate_count, "group")],
        },
    ]


db.create_all()
fill_gender()
appbuilder.add_view(
    GroupModelView,
    "Seznam skupin",
    icon="fa-users",
    category="👥 Kontakty",
    category_icon="fa-address-book",
)
appbuilder.add_view(
    ContactModelView, "Seznam kontaktů", icon="fa-user", category="👥 Kontakty"
)
appbuilder.add_separator("👥 Kontakty")
appbuilder.add_view(
    ContactTimeChartView,
    "Graf narozenin",
    icon="fa-chart-bar",
    category="👥 Kontakty",
)
