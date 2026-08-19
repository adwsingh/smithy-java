/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

package software.amazon.smithy.java.core;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public final class FormatTest2 {
    private final Map<String, List<String>> data;
    private final boolean enabled;

    public FormatTest2(Map<String, List<String>> data, boolean enabled) {
        this.data = data;
        this.enabled = enabled;
    }

    public Optional<List<String>> get(String key) {
        if (enabled) {
            return Optional.ofNullable(data.get(key));
        }
        return Optional.empty();
    }

    public Map<String, List<String>> getAll() {
        return Collections.unmodifiableMap(data);
    }
}
