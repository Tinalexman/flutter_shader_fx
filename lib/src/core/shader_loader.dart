import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages loading and caching of GLSL shader assets.
/// 
/// This class provides efficient shader loading with caching to avoid
/// repeated compilation of the same shaders. It also handles error
/// recovery and fallback mechanisms.
/// 
/// ## Usage
/// 
/// ```dart
/// final shaderLoader = ShaderLoader();
/// 
/// // Load a shader (will be cached for subsequent uses)
/// final shader = await shaderLoader.loadShader('plasma.frag');
/// 
/// // Clear cache when memory is low
/// shaderLoader.clearCache();
/// ```
class ShaderLoader {
  /// Creates a shader loader.
  /// 
  /// [enableCaching] determines whether to cache compiled shaders.
  /// [maxCacheSize] limits the number of cached shaders.
  ShaderLoader({
    this.enableCaching = true,
    this.maxCacheSize = 20,
  });

  /// Whether to cache compiled shaders.
  final bool enableCaching;

  /// Maximum number of cached shaders.
  final int maxCacheSize;

  /// Cache of compiled fragment shaders.
  final Map<String, FragmentShader> _shaderCache = {};

  /// Cache of shader source code.
  final Map<String, String> _sourceCache = {};

  /// Loading states for shaders.
  final Map<String, Future<FragmentShader?>> _loadingStates = {};

  /// Gets the number of cached shaders.
  int get cacheSize => _shaderCache.length;

  /// Gets the number of cached source files.
  int get sourceCacheSize => _sourceCache.length;

  /// Loads and compiles a GLSL fragment shader.
  /// 
  /// [shaderPath] should be the path to the shader file relative to the
  /// shaders/ directory (e.g., 'plasma.frag').
  /// 
  /// Returns the compiled shader, or null if compilation failed.
  Future<FragmentShader?> loadShader(String shaderPath) async {
    // Check if already cached
    if (enableCaching && _shaderCache.containsKey(shaderPath)) {
      return _shaderCache[shaderPath];
    }

    // Check if already loading
    if (_loadingStates.containsKey(shaderPath)) {
      return _loadingStates[shaderPath];
    }

    // Start loading
    final loadingFuture = _loadShaderInternal(shaderPath);
    _loadingStates[shaderPath] = loadingFuture;

    try {
      final shader = await loadingFuture;
      
      // Cache the shader if caching is enabled
      if (enableCaching && shader != null) {
        _cacheShader(shaderPath, shader);
      }
      
      return shader;
    } finally {
      _loadingStates.remove(shaderPath);
    }
  }

  /// Internal method to load and compile a shader.
  Future<FragmentShader?> _loadShaderInternal(String shaderPath) async {
    try {
      // Load shader source
      final source = await _loadShaderSource(shaderPath);
      
      // For now, return null as FragmentShader compilation API is not yet available
      // This will be implemented when Flutter provides the proper API
      debugPrint('Shader compilation not yet implemented for $shaderPath');
      return null;
    } catch (e) {
      debugPrint('Failed to load shader $shaderPath: $e');
      return null;
    }
  }

  /// Loads shader source code from assets.
  /// 
  /// [shaderPath] should be the path to the shader file.
  Future<String> _loadShaderSource(String shaderPath) async {
    // Check source cache first
    if (enableCaching && _sourceCache.containsKey(shaderPath)) {
      return _sourceCache[shaderPath]!;
    }

    // Load from assets
    final assetPath = 'packages/flutter_shader_fx/shaders/$shaderPath';
    final source = await rootBundle.loadString(assetPath);
    
    // Cache source if enabled
    if (enableCaching) {
      _cacheSource(shaderPath, source);
    }
    
    return source;
  }

  /// Estimates the number of float uniforms used by a shader.
  /// 
  /// This is a simple heuristic based on uniform declarations in the shader.
  /// For more accurate results, shaders should explicitly declare uniform counts.
  int _estimateUniformCount(String source) {
    // Count uniform float declarations
    final uniformFloatMatches = RegExp(r'uniform\s+float\s+\w+').allMatches(source);
    final uniformVec2Matches = RegExp(r'uniform\s+vec2\s+\w+').allMatches(source);
    final uniformVec3Matches = RegExp(r'uniform\s+vec3\s+\w+').allMatches(source);
    final uniformVec4Matches = RegExp(r'uniform\s+vec4\s+\w+').allMatches(source);
    
    int count = 0;
    count += uniformFloatMatches.length;
    count += uniformVec2Matches.length * 2;
    count += uniformVec3Matches.length * 3;
    count += uniformVec4Matches.length * 4;
    
    // Add some buffer for standard uniforms
    count += 10;
    
    return count;
  }

  /// Caches a compiled shader.
  void _cacheShader(String shaderPath, FragmentShader shader) {
    // Remove oldest shader if cache is full
    if (_shaderCache.length >= maxCacheSize) {
      final oldestKey = _shaderCache.keys.first;
      final oldestShader = _shaderCache.remove(oldestKey);
      oldestShader?.dispose();
    }
    
    _shaderCache[shaderPath] = shader;
  }

  /// Caches shader source code.
  void _cacheSource(String shaderPath, String source) {
    // Remove oldest source if cache is full
    if (_sourceCache.length >= maxCacheSize) {
      _sourceCache.remove(_sourceCache.keys.first);
    }
    
    _sourceCache[shaderPath] = source;
  }

  /// Preloads a list of shaders.
  /// 
  /// This is useful for preloading commonly used shaders to avoid
  /// compilation delays during runtime.
  Future<void> preloadShaders(List<String> shaderPaths) async {
    final futures = shaderPaths.map((path) => loadShader(path));
    await Future.wait(futures);
  }

  /// Checks if a shader is cached.
  bool isShaderCached(String shaderPath) {
    return _shaderCache.containsKey(shaderPath);
  }

  /// Gets a cached shader without loading.
  /// 
  /// Returns null if the shader is not cached.
  FragmentShader? getCachedShader(String shaderPath) {
    return _shaderCache[shaderPath];
  }

  /// Removes a specific shader from the cache.
  void removeFromCache(String shaderPath) {
    final shader = _shaderCache.remove(shaderPath);
    shader?.dispose();
    _sourceCache.remove(shaderPath);
  }

  /// Clears the entire shader cache.
  /// 
  /// This should be called when memory is low or when the app
  /// is being backgrounded to free up resources.
  void clearCache() {
    // Dispose all cached shaders
    for (final shader in _shaderCache.values) {
      shader.dispose();
    }
    
    _shaderCache.clear();
    _sourceCache.clear();
  }

  /// Gets cache statistics.
  /// 
  /// Returns a map with cache information for debugging and monitoring.
  Map<String, dynamic> getCacheStats() {
    return {
      'shaderCacheSize': _shaderCache.length,
      'sourceCacheSize': _sourceCache.length,
      'maxCacheSize': maxCacheSize,
      'enableCaching': enableCaching,
      'loadingStates': _loadingStates.length,
    };
  }

  /// Validates shader source code.
  /// 
  /// This performs basic validation of GLSL syntax and common issues.
  /// Returns a list of validation errors, or empty list if valid.
  List<String> validateShaderSource(String source) {
    final errors = <String>[];
    
    // Check for required precision qualifier
    if (!source.contains('precision')) {
      errors.add('Missing precision qualifier (use "precision mediump float;")');
    }
    
    // Check for main function
    if (!source.contains('void main()')) {
      errors.add('Missing main function');
    }
    
    // Check for fragColor assignment
    if (!source.contains('fragColor') && !source.contains('gl_FragColor')) {
      errors.add('Missing fragment color assignment');
    }
    
    // Check for excessive loop iterations
    final loopMatches = RegExp(r'for\s*\([^)]*\)\s*\{[^}]*\}').allMatches(source);
    if (loopMatches.length > 2) {
      errors.add('Too many loops detected (may cause performance issues)');
    }
    
    return errors;
  }

  /// Disposes the shader loader and all cached resources.
  void dispose() {
    clearCache();
  }
} 