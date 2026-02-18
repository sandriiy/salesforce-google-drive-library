/**
 * Strategy interface for handling Google API failures inside the library.
 *
 * Implementations provide a consistent failure policy when a {@link GoogleCloudException} occurs.
 * The library will still throw an exception at the point of failure; this strategy is intended
 * for cross-cutting concerns such as standardized logging and diagnostics.
 */
public interface GoogleFailureStrategy {
    void onFailure(GoogleCloudException ex);
}