{#
  By default, dbt prefixes custom schemas with the target schema
  (e.g. "public_staging"). We want models to land in exactly the
  "staging" / "analytics" schemas already used by the raw SQL pipeline,
  so this override uses the custom schema name as-is when one is set.
#}

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
