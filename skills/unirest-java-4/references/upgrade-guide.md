# Upgrade Guide — Full Reference

Complete migration guide for Unirest-Java version upgrades.

## Upgrading to Unirest 4.3

Modules repackaged with new Maven coordinates:

| Old Artifact ID | New Artifact ID | Old Package | New Package |
|----------------|----------------|-------------|-------------|
| `unirest-object-mappers-gson` | `unirest-modules-gson` | `kong.unirest.gson` | `kong.unirest.modules.gson` |
| `unirest-objectmapper-jackson` | `unirest-modules-jackson` | `kong.unirest.jackson` | `kong.unirest.modules.jackson` |
| `unirest-mocks` | `unirest-modules-mocks` | `kong.unirest.core` | `kong.unirest.core` |

## Upgrading to Unirest 4.0

### Requirements
- **Java 11+** (Unirest 4 uses the built-in Java HttpClient)
- **Core package moved**: `kong.unirest` → `kong.unirest.core`

### Maven Changes

Use the BOM for module management:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.konghq</groupId>
            <artifactId>unirest-java-bom</artifactId>
            <version>4.5.1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>com.konghq</groupId>
        <artifactId>unirest-java-core</artifactId>
    </dependency>
    <!-- Choose ONE: -->
    <dependency>
        <groupId>com.konghq</groupId>
        <artifactId>unirest-modules-gson</artifactId>
    </dependency>
</dependencies>
```

### Behavior Differences

| Change | Details |
|--------|---------|
| Null headers | Represented by empty string instead of null |
| Header order | May differ from Apache ordering |
| Host header | Cannot override by default (Java 11+ restriction) |
| Cookie management | Follows more modern standards |
| `cookieSpec()` removed | Was Apache-specific |
| Per-request proxies removed | Only global proxy supported |
| Custom HostNameVerifier removed | No longer supported |
| Socket timeout merged | Combined with connection timeout |
| Shutdown hooks removed | No monitoring threads to shut down |
| System proxy props | Defaults to `false` (was `true` in 3.x) |
| Max concurrent routes removed | Was Apache-specific; `concurrency(int,int)` removed |

## Upgrading to Unirest 3.0

### Key Change: org.json Replacement

The `org.json` dependency was replaced with a clean-room implementation using Google Gson as the engine (namespace: `kong.unirest.core.json`).

**Why?** The org.json license requires "The Software shall be used for Good, not Evil" — many organizations (Eclipse, Debian, Apache) forbid it.

**Differences from org.json:**
- Namespace: `kong.unirest.core.json`
- Most public interfaces honored (JSONArray, JSONObject, JSONPointer)
- Utility classes (XML-to-JSON, CSV-to-JSON) NOT implemented
- `toString(int spaces)` always uses 2 spaces
- Some error message details differ slightly

## Upgrading to Unirest 2.0

- **Java 8 required** (lambda support)
- Package: all main classes in `kong.unirest`
- `.asBinary()` and `.getRawResponse()` removed → use `thenConsume(Consumer<RawResponse>)`
- Apache classes removed from public interfaces
- Configuration centralized in `Unirest.config()`
